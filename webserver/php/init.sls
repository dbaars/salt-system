# Install php

php:
  pkg.installed: []
  service.running:
    - require:
      - pkg: php