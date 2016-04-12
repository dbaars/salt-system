# Install and start httpd/apache

httpd:
  pkg.installed: []
  service.running:
    - require:
      - pkg: httpd

# manage index.html

/var/www/index.html:
  file:
    - managed
    - source: salt://webserver/index.html
    - require:
      - pkg: httpd

# Open firewall ports for http

public:
  firewalld.present:
    - name: public
    - services:
      - http

# What this means is that the service.running state will look for changes to the firewalld.present state 
# and reload firewalld if changes occur

firewalld:
  service.running:
    - reload: True
    - watch:
      - firewalld: public
