FROM python:3.13-slim-bookworm AS builder

RUN apt-get update && apt-get install curl wget gnupg2 libreadline-dev inetutils-telnet -y \
    && apt-get install -y --no-install-recommends gcc \
    && apt-get clean

RUN apt-get update &&  \
    rm -rf /var/lib/apt/lists/* /var/cache/apt

COPY requirements.txt /src/requirements.txt
WORKDIR /src

ARG PIP_CACHE_DIR
ENV PIP_CACHE_DIR ${PIP_CACHE_DIR}

RUN python -m pip install --upgrade pip
RUN python -m pip install -r requirements.txt

FROM builder
COPY core /src/core

EXPOSE 8069/tcp

CMD ["/bin/bash","-c","python3 odoo-bin --addons-path=odoo/enterprise-addons -d odoo -r odoo -w odoo -i base"]
