#!/bin/bash

# Récupération des variables d'env passées au container
printenv > /etc/environment

exec "$@"