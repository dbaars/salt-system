# Install the php-pgsql package
# Require that the php.sls (webserver/php/init.sls) is installed first

include:
  - php

php-pgsql:
  pkg.installed:
    - name: php-pgsql
    - require:
      - sls: php