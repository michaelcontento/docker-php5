FROM debian

RUN EXTENSIONS="php5-curl php5-mcrypt php5-intl php5-pgsql" \
    && export DEBIAN_FRONTEND=noninteractive \
    && echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/02apt-speedup \
    && apt-get update \
    && apt-get install --yes --no-install-recommends php5-cli php5-fpm php-apc procps \
    && apt-get install --yes --no-install-recommends $EXTENSIONS \
    && rm -rf /var/lib/apt/lists/* \
    # == php-fpm pool settings
    && INI="/etc/php5/fpm/pool.d/www.conf" \
    && echo 'listen = 9000' >> $INI \
    && echo 'php_admin_value[error_log] = /dev/stderr' >> $INI \
    && echo 'php_flag[display_errors] = off' >> $INI \
    && echo 'php_flag[log_errors] = on' >> $INI \
    && echo 'php_value[default_charset] = utf-8' >> $INI \
    && echo 'request_slowlog_timeout = 60s' >> $INI \
    && echo 'slowlog = /dev/stdout' >> $INI \
    # == php-fpm settings
    && INI="/etc/php5/fpm/php-fpm.conf" \
    && sed -i -e "s/;daemonize = .*/daemonize = Off/" $INI \
    && sed -i -e "s/error_log = .*/error_log = \/dev\/stderr/" $INI \
    # == settings for both php and php-fpm
    && INI="/etc/php5/conf.d/00-defaults.ini" \
    && echo "cgi.fix_pathinfo = 0" >> $INI \
    && echo "date.timezone = UTC" >> $INI \
    && echo "error_log = /dev/stderr" >> $INI \
    && echo "error_reporting = E_ALL" >> $INI \
    && echo "expose_php = Off" >> $INI

RUN OPTS="--install-dir=/usr/bin/ --filename=composer" \
    && php -r "readfile('https://getcomposer.org/installer');" | php -- $OPTS

ADD server.bash /usr/local/bin/server
CMD ["server"]

VOLUME /var/www
WORKDIR /var/www

EXPOSE 9000

ONBUILD ADD . /var/www
ONBUILD RUN [ -f composer.json ] && composer install || true
