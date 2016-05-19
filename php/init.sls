# Install php

php:
  pkg.installed: []
  
/etc/php.ini:
  file.managed:
    - source: salt://php/files/php.ini.template
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: php