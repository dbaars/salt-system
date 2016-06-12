# key is "vhost_applicationmessages" or "vhost_styles2" etc
# value is e.g. applicationmessages.niwa.co.nz

include:
  - webserver
  - filesystem.www-vhosts.sls

# Open HTTPS port if https_vhost pillar exists
{% if key.startswith('https_vhost') %}
include:
  - firewall.public.https_service
{% endif %}
  
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

/etc/httpd/vhosts.d/{{ vhost_val}}.conf:
  file.managed:
    - source: salt://webserver/vhosts/files/http_vhost.template
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