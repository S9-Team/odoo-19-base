#!/bin/bash
set -e

if [ "$(id -u)" != "0" ]; then
    echo "Running as root to set up directories..."
    exec sudo "$0" "$@"
fi

echo "Generating odoo.conf from environment variables..."
runuser -u odoo -- python3 /mnt/scripts/create_config_file.py

mkdir -p /var/lib/odoo/.local/share/Odoo/sessions
chown -R odoo:odoo /var/lib/odoo/.local/share/Odoo

if [ ! -d "/mnt/backups" ]; then
    mkdir -p /mnt/backups
fi
chown -R odoo:odoo /mnt/backups
chmod -R 755 /mnt/backups


# Ejecutar el comando original (Odoo)
exec runuser -u odoo -- "$@"