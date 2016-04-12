# Install and start httpd/apache

httpd:
  pkg.installed: []
  service.running:
    - require:
      - pkg: httpd

# manage index.html

/var/www/index.html:                        # ID declaration
  file:                                     # state declaration
    - managed                               # function
    - source: salt://webserver/index.html   # function arg
    - require:                              # requisite declaration
      - pkg: httpd                          # requisite reference

# Open firewall ports for http

public:
  firewalld.present:
    - name: public
    - add_service: http
