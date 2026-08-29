import os
from dotenv import load_dotenv

load_dotenv('/.env')

class ConfigFile:
    def __init__(self, path: str):
        self.path = path
        self.content = {
            "db_host": os.getenv("DB_HOST", "db"),
            "db_port": os.getenv("DB_PORT", 5432),
            "db_user": os.getenv("DB_USER", "postgres"),
            "db_password": os.getenv("DB_PASSWORD", "postgres"),
            "db_name": os.getenv("DB_NAME", None),
            "dbfilter": os.getenv("DB_FILTER", "odoo_*"),
            "addons_path": "/mnt/enterprise-addons,/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons",
            "list_db": os.getenv("LIST_DB", True),
            "proxy_mode": os.getenv("PROXY_MODE", True),
            "limit_time_real": os.getenv("LIMIT_TIME_REAL", 1200),
            "limit_request": os.getenv("LIMIT_REQUEST", 655360),
            "limit_time_real_cron": os.getenv("LIMIT_TIME_REAL_CRON", -1),
            "workers": os.getenv("WORKERS", 2),
            "limit_time_worker_cron": os.getenv("LIMIT_TIME_WORKER_CRON", 0),
            "limit_time_cpu": os.getenv("LIMIT_TIME_CPU", 600)
        }

    def create_config_file(self):
        with open(self.path, 'w') as file:
            file.write("[options]\n")
            for key, value in self.content.items():
                file.write(f"{key} = {value}\n")

ConfigFile("/etc/odoo/odoo.conf").create_config_file()