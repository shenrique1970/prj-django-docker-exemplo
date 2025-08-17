# Blog

- Este é um teste usando python postgresql docker.

### requirements.txt
    Django>=3.2.4,<3.3
    psycopg2>=2.8.0,<2.9

### criar arquivos
.dockerignore
.gitignore

### criar pasta app/

### criar arquivo Dockerfile

### arquivo Dockerfile 
<code>

    FROM python:3.9-alpine3.13

    <!--Instala o uv-->
    RUN apk add --no-cache curl && \
        curl -LsSf https://astral.sh/uv/install.sh | sh

    <!--Copia arquivos-->
    COPY ./requirements.txt /tmp/requirements.txt
    COPY ./app /app

    <!--Define diretório de trabalho-->
    WORKDIR /app
    EXPOSE 8000

    <!--Instala dependências e adiciona usuário-->
    RUN apk add --update --no-cache postgresql-client && \
        apk add --update --no-cache --virtual .tmp-build-deps \
            build-base postgresql-dev musl-dev && \
        uv venv /uv && \
        /uv/bin/uv pip install -r /tmp/requirements.txt && \
        rm -rf /tmp && \
        apk del .tmp-build-deps && \
        adduser -D -H django-user

    <!--Garante que o ambiente virtual seja usado por padrão-->
    ENV PATH="/uv/bin:$PATH"

    USER django-user

</code>

### criar arquivo docker-compose.yml

<code>

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
            sh -c "/uv/bin/python manage.py migrate && exec /uv/bin/python manage.py runserver 0.0.0.0:8000"


        environment:
        - DB_HOST=db
        - DB_NAME=postgres
        - DB_USER=postgres
        - DB_PASSWORD=postgres
        depends_on:
        - db

    volumes:
    db_python:

</code>

### buildar 
<code>
docker-compose build
</code>

###
<code>
docker-compose up --build --force-recreate
</code>

### cria projeto app/ dentro da pasta app
<code>
docker compose run --rm app sh -c "django-admin startproject app ."
</code>

### dentro do projeto app/settings.py
    import os
    ...

    DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql',
        'NAME': os.environ.get('DB_NAME', 'DB_NAME'),
        'HOST': os.environ.get('DB_HOST', 'DB_HOST'),
        'USER': os.environ.get('DB_USER', 'DB_USER'),
        'PASSWORD': os.environ.get('DB_PASSWORD', 'DB_PASSWORD'),
        
        }
    }

...



LANGUAGE_CODE = 'pt-br'

TIME_ZONE = 'America/Sao_Paulo'

USE_I18N = True

USE_L10N = True

USE_TZ = True

...

STATIC_URL = '/static/'

...

### iniciar servidor
<code>
docker compose up
</code>

### django
http://127.0.0.1:8000

### cria usuario django
<code>
docker compose run  app sh -c "python manage.py createsuperuser"
</code>

### pgadmin https://www.pgadmin.org/download/pgadmin-4-apt/


### http://127.0.0.1/pgadmin4/browser/


### docker compose up


### apps
<code>
docker compose run  app sh -c "python manage.py startapp contato"
</code>






