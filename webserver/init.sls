# Install and start httpd

include:
  - php
  - php.php-common
  - php.php-pgsql
  - users.jenkins
  - webserver.vhosts.vhost_create
  - webserver.mod_ssl
  - firewalld.public.http_service

# Install httpd
httpd:
  pkg.installed:
    - name: httpd
  service.running:
    - require:
      - pkg: httpd
    - enable: True

# Manage the httpd.conf file
/etc/httpd/conf/httpd.conf:
  file.managed:
    - source: salt://webserver/files/httpd.conf.template
    - mode: 644
    - user: root
    - group: root

# Set permissions on the www dir
/srv/www/:
  file.directory:
    - user: apache
    - group: apache
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group

apache-reload:
  module.wait:
    - name: service.reload
    - m_name: httpd

apache-restart:
  module.wait:
    - name: service.restart
    - m_name: httpd