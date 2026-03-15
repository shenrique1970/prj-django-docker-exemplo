markdown
# Blog - Django + PostgreSQL + Docker

Este é um teste usando **Python**, **PostgreSQL** e **Docker**.

---

## 📋 Requisitos
- Django >= 3.2.4,<3.3  
- psycopg2 >= 2.8.0,<2.9  

Arquivo `requirements.txt`:
```text
Django>=3.2.4,<3.3
psycopg2>=2.8.0,<2.9
🗂 Estrutura
.dockerignore

.gitignore

Dockerfile

docker-compose.yml

Pasta app/

🐳 Dockerfile
dockerfile

<code>

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

</code>

# Garante que o ambiente virtual seja usado por padrão
ENV PATH="/uv/bin:$PATH"

USER django-user
⚙️ docker-compose.yml
yaml
version: '3.0'

services:
  db:
    image: postgres:13-alpine
    volumes:
      - db_python:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=postgres
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
    ports:
      - "5432:5432"

  app:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "8000:8000"
    volumes:
      - ./app:/app
    command: >
      sh -c "/uv/bin/python manage.py migrate &&
             exec /uv/bin/python manage.py runserver 0.0.0.0:8000"
    environment:
      - DB_HOST=db
      - DB_NAME=postgres
      - DB_USER=postgres
      - DB_PASSWORD=postgres
    depends_on:
      - db

volumes:
  db_python:
🚀 Comandos principais
Buildar containers
bash
docker-compose build
Subir containers
bash
docker-compose up --build --force-recreate
Criar projeto Django
bash
docker compose run --rm app sh -c "django-admin startproject app ."
Criar app dentro do projeto
bash
docker compose run app sh -c "python manage.py startapp contato"
⚙️ Configuração do banco (settings.py)
python
import os

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'DB_NAME'),
        'HOST': os.environ.get('DB_HOST', 'DB_HOST'),
        'USER': os.environ.get('DB_USER', 'DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'DB_PASSWORD'),
    }
}

LANGUAGE_CODE = 'pt-br'
TIME_ZONE = 'America/Sao_Paulo'
USE_I18N = True
USE_L10N = True
USE_TZ = True

STATIC_URL = '/static/'
🌐 Acessos
Django: http://127.0.0.1:8000

PgAdmin: http://127.0.0.1/pgadmin4/browser/

👤 Criar superusuário
bash
docker compose run app sh -c "python manage.py createsuperuser"
