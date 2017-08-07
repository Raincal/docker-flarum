FROM wonderfall/nginx-php

LABEL description "Next-generation forum software that makes online discussion fun" \
      maintainer="Hardware <hardware@mondedie.fr>, Magicalex <magicalex@mondedie.fr>, Raincal <cyj94228@gmail.com>"

ARG VERSION=v0.1.0-beta.7

ENV GID=991 UID=991 UPLOAD_MAX_SIZE=50M MEMORY_LIMIT=128M

RUN apk update && apk upgrade && \
    apk add --no-cache git

RUN apk add -U curl \
 && cd /tmp \
 && curl -s http://getcomposer.org/installer | php \
 && mv /tmp/composer.phar /usr/bin/composer \
 && chmod +x /usr/bin/composer \
 && mkdir -p /flarum/app \
 && chown -R $UID:$GID /flarum \
 && COMPOSER_CACHE_DIR="/tmp" su-exec $UID:$GID composer create-project flarum/flarum /flarum/app $VERSION --stability=beta \
 && cd /flarum/app \
 && rm -r composer.json \
 && wget https://gist.githubusercontent.com/Raincal/a3e7bc300cd23ce1178b1a869810f877/raw/2364120b4b90ca118e564e308dba0ce8c929d510/composer.json \
 && composer update \
 && composer dump-autoload --optimize \
 && composer clear-cache \
 && rm -rf /flarum/.composer /var/cache/apk/*

COPY rootfs /
RUN chmod +x /usr/local/bin/* /etc/s6.d/*/* /etc/s6.d/.s6-svscan/*
VOLUME /flarum/app/assets /flarum/app/extensions
EXPOSE 8888
CMD ["run.sh"]
