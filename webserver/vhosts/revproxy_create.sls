# key is "revproxy_cidev" or "revproxy_styles2" etc
# value is FQDN of the website - e.g. cidev.niwa.local

include:
  - apache

{% for key, revproxy_val in pillar.items() if key.startswith('localrevproxy') %}

/etc/httpd/vhosts.d/{{ revproxy_val}}.conf:
  file.managed:
    - source: salt://webserver/vhosts/localrevproxy.template
    - template: jinja
    - defaults:
      vhost_val: {{ vhost_val }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-reload

{% endfor %}