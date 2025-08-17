FROM python:3.9-alpine3.13

# Instala o uv
RUN apk add --no-cache curl && \
    curl -LsSf https://astral.sh/uv/install.sh | sh

# Copia arquivos
COPY ./requirements.txt /tmp/requirements.txt
COPY ./app /app

# Define diretório de trabalho
WORKDIR /app
EXPOSE 8000

# Instala dependências e adiciona usuário
RUN apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    uv venv /uv && \
    /uv/bin/uv pip install -r /tmp/requirements.txt && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser -D -H django-user

# Garante que o ambiente virtual seja usado por padrão
ENV PATH="/uv/bin:$PATH"

USER django-user
