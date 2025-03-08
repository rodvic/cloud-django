# Django build

> Reference: [Getting started with Django](https://www.djangoproject.com/start/)

## Initial requirements

- python3

- Install requirements:

```bash
python3 -m venv cloud-venv
source cloud-venv/bin/activate
pip install -r requirements.txt
```

## Create default site

```bash
django-admin startproject mysite
```

> NOTE: Already created in reposity

## Run from local

```bash
python mysite/manage.py runserver
```

> Access URL: [localhost:8000](http://127.0.0.1:8000/)

## Build django docker

> Reference: [Docker - Get started](https://docs.docker.com/get-started/)

```bash
docker build --load --pull -t cloud-django:latest .
```

### Run from docker local

```bash
docker run --rm -p 8000:8000 cloud-django:latest
```

> Access URL: [localhost:8000](http://127.0.0.1:8000/)
