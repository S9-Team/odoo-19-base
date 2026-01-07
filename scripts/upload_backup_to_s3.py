import os
from S3Repository import S3Repository
from dotenv import load_dotenv

load_dotenv('/.env')

def upload_backup_to_s3(file_path: str, key: str):
    s3_repository = S3Repository(
        bucket_name=os.getenv("S3_BUCKET_NAME"), 
        access_key=os.getenv("S3_ACCESS_KEY"), 
        secret_key=os.getenv("S3_SECRET_KEY")
    )
    return s3_repository.upload(file_path, key)

app_name = os.getenv("APP_NAME")
backup_dir = "/mnt/backups"
s3_dir = f"/odoo/backups/{app_name}"
backup_files = os.listdir(backup_dir)
for backup_file in backup_files:
    # delete files with bk_ prefix
    if backup_file.startswith("bk_"):
        os.remove(os.path.join(backup_dir, backup_file))
        continue

    uploaded = upload_backup_to_s3(os.path.join(backup_dir, backup_file), f"{s3_dir}/{backup_file}")
    if not uploaded:
        print(f"Failed to upload {backup_file}")
        continue

    print(f"Uploaded {backup_file} to S3")

    os.rename(os.path.join(backup_dir, backup_file), os.path.join(backup_dir, f"bk_{backup_file}"))