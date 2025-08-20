#!/bin/bash

set -e

# Чтение пароля из файла, если переменная PASSWORD_FILE установлена
if [ -n "$PASSWORD_FILE" ] && [ -f "$PASSWORD_FILE" ]; then
    PASSWORD=$(cat "$PASSWORD_FILE")
fi

# Установка переменных окружения для базы данных
: "${HOST:=${DB_PORT_5432_TCP_ADDR:=db}}"
: "${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}"
: "${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:=odoo}}}"
: "${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:=odoo}}}"

# Функция для проверки конфигурации и добавления аргументов
DB_ARGS=""
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" | cut -d " " -f3 | sed 's/["\n\r]//g')
    fi
    DB_ARGS="$DB_ARGS --${param} ${value}"
}

# Проверка параметров конфигурации
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

# Отладочная информация
echo "Starting Odoo with the following parameters:"
echo "- DB Host: $HOST"
echo "- DB Port: $PORT"
echo "- DB User: $USER"
echo "- DB Args: $DB_ARGS"

# Проверка доступности команды odoo
if ! command -v odoo >/dev/null 2>&1; then
    echo "Error: 'odoo' command not found. Check if /opt/odoo/odoo-bin exists and is executable."
    ls -l /opt/odoo/odoo-bin
    exit 1
fi

# Ожидание готовности базы данных
if [ -f /usr/local/bin/wait-for-psql.py ]; then
    /usr/local/bin/wait-for-psql.py $DB_ARGS --timeout=30
else
    echo "Warning: wait-for-psql.py not found, skipping database check."
fi

# Запуск Odoo
case "$1" in
    -- | odoo)
        exec odoo "$@" $DB_ARGS -i base
        ;;
    *)
        exec "$@"
esac

exit 1