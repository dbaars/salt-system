# Install the php-pgsql package
# Require that the php.sls (webserver/php/init.sls) is installed first

include:
  - webserver/php

php-pgsql:
  pkg.installed:
    - name: php-pgsql
    - require:
      - sls: webserver/php