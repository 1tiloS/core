#!/bin/sh
set -e

# Настройки базы данных по умолчанию
: "${ODOO_DB:=odoo_db}"
: "${ODOO_DB_USER:=odoo}"
: "${ODOO_DB_PASSWORD:=odoo}"
: "${ODOO_DB_HOST:=db}"

# Проверка и вывод параметров запуска
echo "Starting Odoo with the following parameters:"
echo "- DB: $ODOO_DB"
echo "- DB Host: $ODOO_DB_HOST"
echo "- DB User: $ODOO_DB_USER"

# Если переданы аргументы — исполняем их (например, bash)
if [ "$1" != "odoo" ]; then
    exec "$@"
else
    exec odoo \
        --db_host="$ODOO_DB_HOST" \
        -r "$ODOO_DB_USER" \
        -w "$ODOO_DB_PASSWORD" \
        -d "$ODOO_DB"
        -i base \
        --addons-path="/mnt/addons,/mnt/enterprise-addons,/var/lib/odoo" \
        "$@"
fi