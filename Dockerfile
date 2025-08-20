FROM odoo:18

USER root
RUN apt-get update && \
    apt-get install -y \
        libcups2-dev \
        python3 \
        python3-dev \
        build-essential \
        libssl-dev \
        libffi-dev
USER odoo