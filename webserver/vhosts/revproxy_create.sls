# key is "revproxy_cidev" or "revproxy_styles2" etc
# value is FQDN of the website - e.g. cidev.niwa.local
# MUST have a valid certifiate in pillar {{ key }}_cert and {{ key }}_privatekey

include:
  - apache

{% for key, value in pillar.items() if key.startswith('localrevproxy_') %}

/etc/httpd/vhosts.d/{{ value }}.conf:
  file.managed:
    - source: salt://webserver/vhosts/localrevproxy.template
    - template: jinja
    - defaults:
      vhost_val: {{ value }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: apache
    - watch_in:
      - module: apache-reload

/etc/pki/tls/certs/{{ value }}.pem:
  file.managed:
    - mode: 444
    - user: root
    - group: root
    - contents_pillar: localrevproxycert__jenkins
  selinux.boolean:
    - name: httpd_can_network_connect
    - value: true
    - persist: true
    - require:
      - pkg: apache
      - pkg: mod_ssl
    - require_in:
      - sls: webserver.vhosts.revproxy_create
    - watch_in:
      - module: apache-restart

/etc/pki/tls/private/{{ value }}.key:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents_pillar: localrevproxyprivatekey_jenkins
    - require:
      - pkg: apache
      - pkg: mod_ssl
    - require_in:
      - sls: webserver.vhosts.revproxy_create
    - watch_in:
      - module: apache-restart

{% endfor %}