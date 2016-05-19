# Installs (among other things) php-phpunit
# Require that the php.sls (webserver/php/init.sls) is installed first

include:
  - php

# Install phpunit
php-phpunit-PHPUnit:
  pkg.installed: []
    - require:
      - sls: php