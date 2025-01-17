#!/bin/bash

# Récupération des variables d'env passées au container
printenv > /etc/environment

echo "<?php phpinfo(); ?>" > /var/www/html/public/index.php
exec "$@"