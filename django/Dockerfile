############################################################
# Dockerfile to build Django Application Containers
# Based on Python 3.13
############################################################

FROM python:3.13-slim-bookworm as dependencies

COPY requirements-prod.txt requirements.txt /code/

RUN pip3 install pip==24.3.1 -r /code/requirements-prod.txt

############################################################
# Dockerfile to run Django Application Containers
# Based on Python 3.13
############################################################

FROM python:3.13-slim-bookworm

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y nginx nginx-extras && \
    apt-get upgrade -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=dependencies /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=dependencies /usr/local/bin /usr/local/bin
COPY ./conf /code/conf
COPY ./mysite /code/mysite
COPY supervisord.conf /code/supervisord.conf

WORKDIR /code

CMD ["supervisord", "-c", "/code/supervisord.conf"]
