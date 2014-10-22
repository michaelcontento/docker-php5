#!/usr/bin/env bash

if [ $# -eq 0 ] || [ $1 == "serve" ]; then
    echo "===> Running php5-fpm"
    shift
    exec php5-fpm $@
elif [ $1 == "composer" ]; then
    echo "===> Running composer"
    shift
    exec composer $@
else
    echo "===> Running command"
    exec php app/console $@
fi
