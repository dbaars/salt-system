# key is "vhost_applicationmessages" or "vhost_styles2" etc
# value is e.g. applicationmessages.niwa.co.nz

include:
  - webserver
  - filesystem.www-vhosts

# Open HTTPS port if https_vhost pillar exists
# Manage the ssl.conf configuration and default vhost file
{% for key, vhost_val in pillar.items() if key.startswith('https_vhost') %}
include:
  - firewalld.public.https_service

# Create the default vhost file
/etc/httpd/conf.d/ssl.conf:
  file.managed:
    - source: salt://webserver/vhosts/files/ssl.conf.template
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: httpd
    - watch_in:
      - module: apache-reload
{% endfor %}
  
# Create the vhosts.d directory to store vhost conf files
/etc/httpd/vhosts.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

# Create the vhosts directory
/srv/www/vhosts/:
  file.directory:
    - user: apache
    - group: apache
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
  acl.present:
    - acl_type: user
    - acl_name: jenkins
    - perms: rwx
    - recurse: True

# Create the default vhost file
/etc/httpd/vhosts.d/default.conf:
  file.managed:
    - source: salt://webserver/vhosts/files/default.conf.template
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: httpd
    - watch_in:
      - module: apache-reload

########################
# Create HTTP-only vhost
########################
{% for key, vhost_val in pillar.items() if key.startswith('http_vhost') %}

# Grab the name of the vhost (we need it to match other pillars later on)
# E.g. This extracts 'ecwdbadmin' from a pillar called 'http_vhost_ecwdbadmin'
{% set host=key.split('_')[2] %}

/var/www/html/vhosts/{{ vhost_val }}:
  file.directory:
    - user: apache
    - group: apache
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - pkg: httpd
  acl.present:
    - acl_type: user
    - acl_name: jenkins
    - perms: rwx
    - recurse: True
	
# A quick for loop to extract the documentroot from pillar
{% for key1, docroot in pillar.items() if (key1.startswith('documentroot') and (host in key1)) %}

/etc/httpd/vhosts.d/{{ vhost_val}}.conf:
  file.managed:
    - source: salt://webserver/vhosts/files/http_vhost.template
    - template: jinja
    - defaults:
      vhost_val: {{ vhost_val }}
      docroot_val: {{ docroot }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: httpd
    - watch_in:
      - module: apache-reload

{% endfor %}
{% endfor %}

####################
# Create HTTPS vhost
####################
{% for key, vhost_val in pillar.items() if key.startswith('https_vhost') %}
/var/www/html/vhosts/{{ vhost_val }}:
  file.directory:
    - user: apache
    - group: apache
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
    - require:
      - pkg: httpd
  acl.present:
    - acl_type: user
    - acl_name: jenkins
    - perms: rwx
    - recurse: True

/etc/pki/tls/certs/{{ vhost_val }}.pem:
  file.managed:
    - mode: 444
    - user: root
    - group: root
    - contents_pillar: {{ vhost_val }}_cert
    - require_in:
      - file: /etc/httpd/vhosts.d/{{ vhost_val }}.conf
  selinux.boolean:
    - name: httpd_can_network_connect
    - value: true
    - persist: true

/etc/pki/tls/private/{{ vhost_val }}.key:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents_pillar: {{ vhost_val }}_privatekey
    - require_in:
      - file: /etc/httpd/vhosts.d/{{ vhost_val }}.conf


/etc/httpd/vhosts.d/{{ vhost_val}}.conf:
  file.managed:
    - source: salt://webserver/vhosts/files/https_vhost.template
    - template: jinja
    - defaults:
      vhost_val: {{ vhost_val }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: httpd
    - watch_in:
      - module: apache-reload

{% endfor %}