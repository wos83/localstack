# pip install boto3

import os
import boto3
from botocore.exceptions import ClientError

# LocalStack configuration matching the provided bash scripts
ENDPOINT_URL = 'http://127.0.0.1:4566'
AWS_REGION = 'us-east-1'
BUCKET_NAME = 's3-test'
DUMMY_CREDENTIAL = 'test'

def get_localstack_s3_client():
    """
    Initializes and returns a boto3 S3 client configured to point 
    to the local LocalStack endpoint instead of the real AWS cloud.
    """
    return boto3.client(
        's3',
        endpoint_url=ENDPOINT_URL,
        region_name=AWS_REGION,
        aws_access_key_id=DUMMY_CREDENTIAL,
        aws_secret_access_key=DUMMY_CREDENTIAL
    )

def upload_file_to_s3(file_path: str, bucket_name: str, object_name: str = None) -> bool:
    """
    Uploads a file to an S3 bucket.
    
    :param file_path: File to upload
    :param bucket_name: Target bucket
    :param object_name: S3 object name. If not specified, file_name is used
    :return: True if file was uploaded, else False
    """
    if object_name is None:
        object_name = os.path.basename(file_path)

    s3_client = get_localstack_s3_client()

    try:
        print(f"Uploading '{file_path}' to bucket '{bucket_name}' as '{object_name}'...")
        s3_client.upload_file(file_path, bucket_name, object_name)
        print("Upload successful!")
        return True
    except ClientError as e:
        print(f"Failed to upload file. Error: {e}")
        return False

def list_bucket_objects(bucket_name: str):
    """
    Lists all objects currently stored in the specified S3 bucket.
    """
    s3_client = get_localstack_s3_client()
    
    try:
        response = s3_client.list_objects_v2(Bucket=bucket_name)
        if 'Contents' in response:
            print(f"\nObjects found in '{bucket_name}':")
            for obj in response['Contents']:
                print(f" - {obj['Key']} (Size: {obj['Size']} bytes)")
        else:
            print(f"\nThe bucket '{bucket_name}' is empty.")
    except ClientError as e:
        print(f"Failed to list objects. Error: {e}")

if __name__ == "__main__":
    # 1. Create a temporary dummy file to test the upload
    test_file_name = "sample_data.txt"
    with open(test_file_name, "w") as f:
        f.write("This is a test payload for LocalStack S3 integration.")

    # 2. Upload the file
    upload_success = upload_file_to_s3(
        file_path=test_file_name,
        bucket_name=BUCKET_NAME
    )

    # 3. Verify the upload by listing the bucket contents
    if upload_success:
        list_bucket_objects(bucket_name=BUCKET_NAME)

    # 4. Clean up the local dummy file
    if os.path.exists(test_file_name):
        os.remove(test_file_name)