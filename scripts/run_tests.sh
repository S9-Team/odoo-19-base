#!/bin/bash

# Script para ejecutar tests de módulos en Odoo 19
# Uso: ./run_tests.sh <nombre_del_modulo> [database_name]

MODULE=${1:-web_m2x_options}
DB_NAME=${2:-odoo19}

echo "========================================"
echo "Running tests for module: $MODULE"
echo "Database: $DB_NAME"
echo "========================================"

# Opción 1: Ejecutar tests sin detener el servidor (usando workers 0)
docker exec odoo19 odoo \
  --test-enable \
  --stop-after-init \
  --workers=0 \
  --database=$DB_NAME \
  --update=$MODULE \
  --test-tags=$MODULE \
  --log-level=test \
  --without-demo=all

EXIT_CODE=$?

echo ""
echo "========================================"
if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ Tests completed successfully for $MODULE"
else
    echo "❌ Tests failed for $MODULE (Exit code: $EXIT_CODE)"
fi
echo "========================================"

exit $EXIT_CODE

