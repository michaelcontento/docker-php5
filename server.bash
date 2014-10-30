#!/usr/bin/env bash
set -e

log() {
    echo $@
}

error() {
    log "ERROR: $@"
    exit 1
}

get_environment_vars() {
    for name in $(env | grep -o '.*_NAME='); do
        env | grep ${name%_NAME=}
    done | sort | uniq
}

clear_environment() {
    local cfg=$1
    [ -z $cfg ] && error "config file missing"

    sed -i -e '/^[[:space:]]*env\[.*\][[:space:]]*=.*/d' $cfg
}

add_environment() {
    local cfg=$1
    [ -z $cfg ] && error "config file missing"

    for envVar in $(get_environment_vars); do
        local parts=(${envVar/=/ })
        local key=${parts[0]}
        local value=${parts[1]}
        echo "env[$key] = '$value'" >> $cfg
    done
}

clear_environment /etc/php5/fpm/pool.d/www.conf
add_environment /etc/php5/fpm/pool.d/www.conf

exec php5-fpm
