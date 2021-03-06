FROM debian

# TODO: Remove php5-pgsql
RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && apt-get update \
    && apt-get install --yes --no-install-recommends git ca-certificates \
    && apt-get install --yes --no-install-recommends php5-cli php5-fpm php-apc \
    && apt-get install --yes --no-install-recommends php5-mcrypt php5-intl php5-curl \
    && apt-get install --yes --no-install-recommends php5-pgsql \
    && rm -rf /var/lib/apt/lists/*

RUN INI="/etc/php5/fpm/pool.d/www.conf" \
    && echo 'listen = 9000' >> $INI \
    && echo 'php_admin_value[error_log] = stderr' >> $INI \
    && echo 'php_flag[display_errors] = off' >> $INI \
    && echo 'php_flag[log_errors] = on' >> $INI \
    && echo 'php_value[default_charset] = utf-8' >> $INI \
    && echo 'request_slowlog_timeout = 60s' >> $INI \
    && echo 'slowlog = stdout' >> $INI \
    \
    && INI="/etc/php5/fpm/php-fpm.conf" \
    && sed -i -e "s/;daemonize = .*/daemonize = Off/" $INI \
    && sed -i -e "s/error_log = .*/error_log = stderr/" $INI \
    \
    && INI="/etc/php5/conf.d/00-defaults.ini" \
    && echo "date.timezone = UTC" >> $INI \
    && echo "error_log = stderr" >> $INI \
    && echo "error_reporting = E_ALL" >> $INI \
    && echo "expose_php = Off" >> $INI \
    && echo "short_open_tag = Off" >> $INI

# poor man's CI
RUN php5-fpm -t 2>&1

RUN OPTS="--install-dir=/usr/bin/ --filename=composer" \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- $OPTS

ADD server.bash /usr/local/bin/server
CMD ["server"]

VOLUME /var/www
WORKDIR /var/www

EXPOSE 9000

ONBUILD ADD . /var/www
ONBUILD RUN composer selfupdate
ONBUILD RUN [ -f composer.github.token ] \
    && composer config -g github-oauth.github.com $(cat composer.github.token) \
    || true
ONBUILD RUN [ -f composer.json ] \
    && composer install --prefer-dist --optimize-autoloader --no-interaction \
    || true
