#!/usr/bin/env bash

# Récupération des variables d'env passées au container
printenv > /etc/environment

supervisord -c /etc/supervisor/conf.d/supervisord.conf && supervisorctl start all

if [ -f /tmp/entrypoint.sh ]; then
    . /tmp/entrypoint.sh
fi
exec "$@"