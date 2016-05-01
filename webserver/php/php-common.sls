# Installs (among other things) php-gd, php-pdo, php-curl
# Require that the php.sls (webserver/php/init.sls) is installed first

include:
  - webserver.php

php-common:
  pkg.installed:
    - name: php-common
    - require:
      - sls: webserver.php