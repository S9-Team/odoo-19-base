FROM odoo:19

# Cambiar al usuario root para instalar dependencias adicionales
USER root

ARG GIT_TOKEN
ARG GIT_ENTERPRISE_TOKEN
ARG GIT_REPOSITORY
ARG GIT_BRANCH

# Instalar dependencias adicionales si son necesarias
RUN apt-get update && apt-get install -y \
    git \
    && rm -rf /var/lib/apt/lists/*

RUN apt update && \
    apt install -y python3 python3-boto3 postgresql-client curl python3-pip && \
    apt clean

# Instalar python-dotenv para leer archivos .env
RUN pip3 install --break-system-packages python-dotenv


# Crear directorios para addons personalizados
RUN mkdir -p /mnt/extra-addons /mnt/enterprise-addons

# Establecer permisos correctos
RUN chown -R odoo:odoo /mnt/extra-addons /mnt/enterprise-addons

RUN git clone https://$GIT_ENTERPRISE_TOKEN@github.com/odoo/enterprise.git --depth 1 --single-branch 19.0
RUN mv 19.0/* /mnt/enterprise-addons/
RUN git clone https://$GIT_TOKEN@github.com/$GIT_REPOSITORY.git -b $GIT_BRANCH /mnt/extra-addons/

COPY ./scripts/* /mnt/scripts/
COPY ./scripts/entrypoint.sh /mnt/scripts/entrypoint.sh
RUN chmod +x /mnt/scripts/*

# Mantener como root - el entrypoint cambiará al usuario odoo antes de ejecutar Odoo
USER root

# Exponer el puerto de Odoo
EXPOSE 8069 8071 8072

ENTRYPOINT ["/mnt/scripts/entrypoint.sh"]