# Install and start httpd/apache

httpd:
  pkg.installed: []
  service.running:
    - require:
      - pkg: httpd

# manage index.html

/var/www/html/index.html:
  file:
    - managed
    - source: salt://webserver/index.html
    - require:
      - pkg: httpd
    - mode: 644
    - user: apache
    - group: apache

# Open firewall ports for http

public:
  firewalld.present:
    - name: public
    - services:
      - http

# What this means is that the service.running state will look for changes to the firewalld.present state 
# and restart firewalld if changes occur

firewalld:
  service.running:
    - watch:
      - firewalld: public
