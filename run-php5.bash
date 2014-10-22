#!/usr/bin/env bash

if [ $# -eq 0 ] || [ $1 == "serve" ]; then
    echo "===> Running php5-fpm"
    shift
    exec php5-fpm $@
else
    echo "===> Running command"
    exec $@
fi
