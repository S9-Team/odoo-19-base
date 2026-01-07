#!/bin/bash

# Función para cargar variables de entorno desde un archivo .env
load_env_file() {
    local env_file="$1"
    if [ -f "$env_file" ]; then
        echo "Loading environment variables from $env_file..."
        # Exportar todas las variables del archivo .env
        set -a  # Automáticamente exporta todas las variables
        source "$env_file"
        set +a  # Desactiva la exportación automática
        echo "Environment variables loaded."
    else
        echo "Warning: $env_file not found, using default values."
    fi
}

# Cargar variables de entorno desde /.env
load_env_file "/.env"

# Temporary backups folder (Persistent Storage)
BACKUP_DIR="/mnt/backups"

# PostgreSQL configuration (from environment variables or default values)
PGHOST="${DB_HOST:-postgres}"
PGPORT="${DB_PORT:-5432}"
PGUSER="${DB_USER:-odoo}"
PGPASSWORD="${DB_PASSWORD:-odoo}"
DBPREFIX="${DB_PREFIX:-odoo_}"
MASTER_PWD="${MASTER_PASSWORD:-admin}"

export PGPASSWORD

echo "=== Connection configuration ==="
echo "PGHOST: $PGHOST"
echo "PGPORT: $PGPORT"
echo "PGUSER: $PGUSER"
echo ""

# Crear directorio de backups si no existe y verificar permisos
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Creating backup directory: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# Verificar permisos de escritura
if [ ! -w "$BACKUP_DIR" ]; then
    echo "ERROR: No write permission on $BACKUP_DIR"
    echo "Current user: $(whoami)"
    echo "Current UID: $(id -u)"
    echo "Directory permissions: $(ls -ld $BACKUP_DIR)"
    exit 1
fi

echo "Backup directory: $BACKUP_DIR (writable)"
echo ""

# show hours minutes and seconds
DATE=$(date +%F_%H%M%S)

# Verify PostgreSQL connection
echo "=== Verifying PostgreSQL connection ==="
if ! psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c "SELECT 1;" > /dev/null 2>&1; then
    echo "ERROR: Cannot connect to PostgreSQL at $PGHOST:$PGPORT"
    exit 1
fi
echo "Connection successful!"
echo ""

# List ALL databases for debug
echo "=== All available databases ==="
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -t -c "SELECT datname FROM pg_database WHERE datistemplate = false;"
echo ""

# Get all databases with prefixes tenant_, dev_ and staging_
DBS=$(psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -t -c "SELECT datname FROM pg_database WHERE datname LIKE '$DBPREFIX%';" | tr -d ' ')

for DB in $DBS; do
    # Skip empty lines
    [ -z "$DB" ] && continue
    DOMAIN="$APP_DOMAIN"
    
    echo "Backing up $DB..."
    echo "URL: $DOMAIN/web/database/backup"
    
    BACKUP_FILE="$BACKUP_DIR/${DB}_$DATE.zip"
    
    curl -X POST \
        -F "master_pwd=$MASTER_PWD" \
        -F "name=$DB" \
        -F "backup_format=zip" \
        -F "filestore=1" \
        "$DOMAIN/web/database/backup" \
        --output "$BACKUP_FILE"
    
    if [ -f "$BACKUP_FILE" ] && [ -s "$BACKUP_FILE" ]; then
        echo "Backup completed: $BACKUP_FILE ($(du -h "$BACKUP_FILE" | cut -f1))"
    else
        echo "ERROR: Backup file was not created or is empty: $BACKUP_FILE"
    fi
    echo ""
done

echo "All backups completed."
echo "Listing files in $BACKUP_DIR:"
ls -lh "$BACKUP_DIR"