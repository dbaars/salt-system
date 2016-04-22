# Install and start httpd/apache

httpd:
  pkg.installed: []
  service.running:
    - require:
      - pkg: httpd
