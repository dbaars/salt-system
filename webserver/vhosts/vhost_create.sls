# key is "vhost_applicationmessages" or "vhost_styles2" etc
# value is e.g. applicationmessages.niwa.co.nz

{% for key, vhost_val in pillar.items() if key.startswith('vhost') %}
/var/www/html/vhosts/{{ vhost_val }}:
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

/etc/httpd/vhosts.d/{{ vhost_val}}.conf:
  file.managed:
    - source: salt://webserver/vhosts/vhost.template
    - template: jinja
    - mode: 644
    - user: root
    - group: root

{% endfor %}