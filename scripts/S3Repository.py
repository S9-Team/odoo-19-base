import io
import os
import boto3

from boto3.s3.transfer import S3UploadFailedError
from botocore.exceptions import ClientError

class S3Repository:
    """Repository class for managing S3 operations"""
    
    def __init__(self, bucket_name: str, access_key: str, secret_key: str):
        """
        Initialize S3 Repository
        
        Args:
            bucket_name: Name of the S3 bucket
            access_key: AWS access key ID
            secret_key: AWS secret access key
        """
        self.bucket_name = bucket_name
        self.access_key = access_key
        self.secret_key = secret_key
        self.s3 = boto3.client(
            's3',
            aws_access_key_id=self.access_key,
            aws_secret_access_key=self.secret_key,
        )

    def upload(self, file_path: str, key: str) -> bool:
        """
        Upload a file to S3 bucket
        
        Args:
            file_path: Local path to the file
            key: S3 object key (filename in bucket)
            
        Returns:
            bool: True if upload was successful, False otherwise
        """

        try:
            self.s3.upload_file(file_path, self.bucket_name, key)
            return True
        except S3UploadFailedError as e:
            print(f"      ❌ S3 upload error: {e}")
            return False
        except ClientError as e:
            print(f"      ❌ AWS client error: {e}")
            return False
        except Exception as e:
            print(f"      ❌ Unexpected error: {e}")
            return False
