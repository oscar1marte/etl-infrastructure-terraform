import sys
from awsglue.utils import getResolvedOptions
import pandas as pd
import boto3
import json
from botocore.exceptions import ClientError
import snowflake.connector
import os
import hashlib


def md5_number_lower64(msg):
    """
    Generate a 64-bit integer from the lower half of an MD5 hash.

    Args:
        msg (str): The input string to hash.

    Returns:
        int: The lower 64 bits of the MD5 hash.
    """
    md5_digest = hashlib.md5(msg.encode('utf-8')).digest()
    return int.from_bytes(md5_digest[8:], 'big')


def calculate_ordered_md5_number(row, columns):
    """
    Calculate an MD5-based hash for a row based on specified columns.

    Args:
        row (pd.Series): The row of data.
        columns (list): The list of columns to include in the hash calculation.

    Returns:
        int: The MD5-based hash of the concatenated column values.
    """
    ordered_string = ''.join(str(row[column]) for column in columns)
    return md5_number_lower64(ordered_string)


def get_secret(secret_name, region_name):
    """
    Retrieve a secret from AWS Secrets Manager.

    Args:
        secret_name (str): The name of the secret to retrieve.
        region_name (str): The AWS region where the secret is stored.

    Returns:
        str: The secret as a JSON string.
    """
    session = boto3.session.Session()
    client = session.client(service_name='secretsmanager', region_name=region_name)

    try:
        get_secret_value_response = client.get_secret_value(SecretId=secret_name)
    except ClientError as e:
        raise e

    return get_secret_value_response['SecretString']


def download_file_from_s3(bucket_name, file_key, download_path):
    """
    Download a file from an S3 bucket.

    Args:
        bucket_name (str): The name of the S3 bucket.
        file_key (str): The key (path) of the file in the S3 bucket.
        download_path (str): The local path where the file should be saved.

    Returns:
        None
    """
    session = boto3.session.Session()
    s3_client = session.client('s3')

    try:
        s3_client.download_file(bucket_name, file_key, download_path)
        print(f"File {file_key} downloaded successfully to {download_path}")
    except Exception as e:
        print(f"Error downloading file from S3: {e}")


def bulk_load_to_snowflake(
        user, password, account, warehouse, database,
        schema, stage_name, table_name, local_file_path,
        file_format='CSV'
    ):
    """
    Upload and load data from a local file into a Snowflake table.

    Args:
        user (str): Snowflake username.
        password (str): Snowflake password.
        account (str): Snowflake account identifier.
        warehouse (str): Snowflake warehouse name.
        database (str): Snowflake database name.
        schema (str): Snowflake schema name.
        stage_name (str): Snowflake stage name.
        table_name (str): The target table name in Snowflake.
        local_file_path (str): The local path of the file to upload.
        file_format (str, optional): The file format (default is 'CSV').

    Returns:
        None
    """
    conn = snowflake.connector.connect(
        user=user,
        password=password,
        account=account,
        warehouse=warehouse,
        database=database,
        schema=schema
    )
    cur = conn.cursor()
    cur.execute(f'USE {database}.{schema}')
    cur.execute(f'USE WAREHOUSE {warehouse}')

    try:
        file_name = os.path.basename(local_file_path)
        put_command = f"PUT file://{local_file_path} {stage_name}"
        cur.execute(put_command)
        print(f"File {file_name} uploaded to stage {stage_name}.")

        copy_command = f"""
        COPY INTO {table_name}
        FROM {stage_name}/{file_name}.gz
        FILE_FORMAT = (TYPE = '{file_format}')
        ON_ERROR = 'CONTINUE';
        """
        cur.execute(copy_command)
        print(f"Data from {file_name} loaded into table {table_name}.")

        remove_command = f"REMOVE {stage_name}/{file_name}.gz"
        cur.execute(remove_command)
        print(f"File {file_name} removed from stage {stage_name}.")

        conn.commit()

    finally:
        cur.close()
        conn.close()


def loop_bulk_load(
    snowflake_username,
    snowflake_password,
    snowflake_account,
    snowflake_warehouse,
    snowflake_database,
    snowflake_schema,
    snowflake_stage,
    table_list,
    local_path_list
):
    """
    Loop through lists of table names and file paths to perform bulk load into Snowflake.

    Args:
        snowflake_username (str): Snowflake username.
        snowflake_password (str): Snowflake password.
        snowflake_account (str): Snowflake account identifier.
        snowflake_warehouse (str): Snowflake warehouse name.
        snowflake_database (str): Snowflake database name.
        snowflake_schema (str): Snowflake schema name.
        snowflake_stage (str): Snowflake stage name.
        table_list (list): List of Snowflake table names.
        local_path_list (list): List of local file paths corresponding to the tables.

    Returns:
        None
    """
    for table_name, local_path_name in zip(table_list, local_path_list):
        bulk_load_to_snowflake(
            snowflake_username,
            snowflake_password,
            snowflake_account,
            snowflake_warehouse,
            snowflake_database,
            snowflake_schema,
            snowflake_stage,
            table_name,
            local_path_name
        )


def main():
    """
    Main function to execute the ETL process.

    - Retrieves Snowflake credentials from AWS Secrets Manager.
    - Downloads the source CSV file from S3.
    - Processes the CSV file to create specific data frames.
    - Saves processed data frames to local CSV files.
    - Loads the CSV files into Snowflake tables.

    Args:
        None

    Returns:
        None
    """
    args = getResolvedOptions(sys.argv, ['JOB_NAME', 'secret_name', 'region_name', 'bucket_name', 'file_key'])

    secret_name = args['secret_name']
    region_name = args['region_name']
    bucket_name = args['bucket_name']
    file_key = args['file_key']

    # Retrieve Snowflake secrets from AWS Secrets Manager
    snowflake_secrets = json.loads(get_secret(secret_name, region_name))

    # Download the source CSV file from S3
    download_file_from_s3(bucket_name, file_key, file_key)

    # Extract Snowflake connection details
    snowflake_username = snowflake_secrets['username']
    snowflake_password = snowflake_secrets['password']
    snowflake_account = snowflake_secrets['account']
    snowflake_warehouse = snowflake_secrets['warehouse']
    snowflake_database = snowflake_secrets['database']
    snowflake_schema = snowflake_secrets['schema']
    snowflake_stage = snowflake_secrets['stage']

    # Load the data into a DataFrame
    data = pd.read_csv(file_key)
    data.columns = [col.lower().replace(' ', '_') for col in data.columns]

    # Process and deduplicate different data categories
    customer_demographics_columns = [
        'customer_id', 'age', 'gender', 'marital_status', 
        'education_level', 'geographic_information', 
        'occupation', 'income_level'
    ]
    customer_demographics = data[customer_demographics_columns].drop_duplicates()
    customer_demographics['md5_hash'] = customer_demographics.apply(lambda row: calculate_ordered_md5_number(row, customer_demographics_columns), axis=1)

    customer_behavior_columns = [
        'customer_id', 'behavioral_data', 'interactions_with_customer_service', 'purchase_history'
    ]
    customer_behavior = data[customer_behavior_columns].drop_duplicates()
    customer_behavior['purchase_history'] = pd.to_datetime(customer_behavior['purchase_history']).dt.strftime('%Y-%m-%d')
    customer_behavior['md5_hash'] = customer_behavior.apply(lambda row: calculate_ordered_md5_number(row, customer_behavior_columns), axis=1)

    customer_insurance_products_columns = [
        'customer_id', 'insurance_products_owned', 'coverage_amount', 'premium_amount', 'policy_type'
    ]
    customer_insurance_products = data[customer_insurance_products_columns].drop_duplicates()
    customer_insurance_products['md5_hash'] = customer_insurance_products.apply(lambda row: calculate_ordered_md5_number(row, customer_insurance_products_columns), axis=1)

    customer_preferences_columns = [
        'customer_id', 'customer_preferences', 'preferred_communication_channel', 'preferred_contact_time', 'preferred_language'
    ]
    customer_preferences = data[customer_preferences_columns].drop_duplicates()
    customer_preferences['md5_hash'] = customer_preferences.apply(lambda row: calculate_ordered_md5_number(row, customer_preferences_columns), axis=1)

    customer_segmentation_columns = [
        'customer_id', 'segmentation_group'
    ]
    customer_segmentation = data[customer_segmentation_columns].drop_duplicates()
    customer_segmentation['md5_hash'] = customer_segmentation.apply(lambda row: calculate_ordered_md5_number(row, customer_segmentation_columns), axis=1)

    # Save the processed data frames to CSV files
    customer_demographics.to_csv("customer_demographics.csv", index=False)
    customer_behavior.to_csv("customer_behavior.csv", index=False)
    customer_insurance_products.to_csv("customer_insurance_products.csv", index=False)
    customer_preferences.to_csv("customer_preferences.csv", index=False)
    customer_segmentation.to_csv("customer_segmentation.csv", index=False)

    # Prepare the list of tables and corresponding file paths
    table_list = ['customer_demographics', 'customer_behavior', 'customer_insurance_products',
                  'customer_preferences', 'customer_segmentation']
    local_path_list = [f"{col}.csv" for col in table_list]

    # Bulk load each CSV file into the corresponding Snowflake table
    loop_bulk_load(
        snowflake_username,
        snowflake_password,
        snowflake_account,
        snowflake_warehouse,
        snowflake_database,
        snowflake_schema,
        snowflake_stage,
        table_list,
        local_path_list
    )


if __name__ == "__main__":
    main()
