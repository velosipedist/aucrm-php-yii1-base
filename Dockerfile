FROM dmstr/php-yii2:7.1-fpm-3.2-nginx

ENV TZ Europe/Moscow
ENV ACCEPT_EULA=Y

COPY docker-php-ext-enable /usr/bin/docker-php-ext-enable

RUN sed '/jessie-updates main/d' -i /etc/apt/sources.list \
#    && rm -rf /var/lib/apt/lists/* \
#    && apt-get clean \
    && apt-get update \
    && apt-get -y install autoconf build-essential python supervisor tzdata libtidy-dev \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
        unixodbc \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get -y --no-install-recommends install \
        unixodbc-dev \
        pkg-config \
        libc6 \
        libc6-dev \
        libpcre3-dev \
        libc-client-dev libkrb5-dev

COPY msodbcsql_13.1.9.2-1_amd64_debian_jessie.deb /app/
RUN dpkg -i /app/msodbcsql_13.1.9.2-1_amd64_debian_jessie.deb

# PHP extensions
RUN mkdir -p /usr/src/php/ext/redis \
    && curl -L https://github.com/phpredis/phpredis/archive/3.0.0.tar.gz | tar xvz -C /usr/src/php/ext/redis --strip 1 \
    && echo 'redis' >> /usr/src/php-available-exts \
    && docker-php-ext-configure imap --with-kerberos --with-imap-ssl \
    && docker-php-ext-install mbstring pdo pdo_mysql imap calendar redis tidy \
    && pecl install sqlsrv pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv
