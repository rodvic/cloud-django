FROM ubuntu:bionic

RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y python3-pip nginx nginx-extras && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get upgrade -y # Upgrade dependencies

COPY . /code/

RUN pip3 install --upgrade pip==20.2.4 -r /code/requirements-prod.txt

WORKDIR /code

CMD ["supervisord", "-c", "/code/supervisord.conf"]
