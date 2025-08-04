FROM odoo:18

USER root

# Установка зависимостей
RUN apt-get update && \
    apt-get install -y \
        libcups2-dev \
        python3 \
        build-essential \
        libssl-dev \
        libffi-dev \
        dos2unix && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Создание директорий и установка прав
RUN mkdir -p /var/lib/odoo /mnt/enterprise-addons && \
    chown -R odoo:odoo /var/lib/odoo /mnt/enterprise-addons

# Копируем кастомный entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh
# Отладка: проверяем права
RUN ls -l /entrypoint.sh

# Устанавливаем entrypoint и команду по умолчанию
ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]