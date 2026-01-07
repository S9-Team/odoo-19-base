import os
from dotenv import load_dotenv
from datetime import datetime, timedelta

load_dotenv('/.env')

backup_dir = "/mnt/backups"
backup_files = os.listdir(backup_dir)
for backup_file in backup_files:
    file_path_array = backup_file.split("_")
    file_time = file_path_array[len(file_path_array) - 1].split(".")[0]
    file_date = f"{file_path_array[len(file_path_array) - 2]}_{file_time}"
    file_date_obj = datetime.strptime(file_date, "%Y-%m-%d_%H%M%S")
    if file_date_obj < datetime.now() - timedelta(days=7):
        os.remove(os.path.join(backup_dir, backup_file))
        print(f"Deleted {backup_file}")
    else:
        print(f"Skipping {backup_file}")


