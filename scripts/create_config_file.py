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
            "addons_path": "/usr/lib/python3/dist-packages/odoo/addons,/mnt/extra-addons,/mnt/enterprise-addons",
            "list_db": os.getenv("LIST_DB", True),
        }

    def create_config_file(self):
        with open(self.path, 'w') as file:
            file.write("[options]\n")
            for key, value in self.content.items():
                file.write(f"{key} = {value}\n")

ConfigFile("/etc/odoo/odoo.conf").create_config_file()