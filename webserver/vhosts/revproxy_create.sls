# key is "localrevproxy_cidev" or "localrevproxy_styles2" etc
# value is FQDN of the website - e.g. cidev.niwa.local
# MUST have a valid certifiate in pillar value_cert and value_privatekey, where "value" is the FQDN of the website - e.g. cidev.niwa.local_cert and cidev.niwa.local_privatekey

include:
  - webserver

{% for key, value in pillar.items() if key.startswith('localrevproxy_') %}

/etc/httpd/vhosts.d/{{ value }}.conf:
  file.managed:
    - source: salt://webserver/vhosts/files/localrevproxy.template
    - template: jinja
    - defaults:
      vhost_val: {{ value }}
    - mode: 644
    - user: root
    - group: root
    - require:
      - pkg: httpd
    - watch_in:
      - module: apache-reload

/etc/pki/tls/certs/{{ value }}.pem:
  file.managed:
    - mode: 444
    - user: root
    - group: root
    - contents_pillar: {{ value }}_cert
    - require_in:
      - file: /etc/httpd/vhosts.d/{{ value }}.conf
  selinux.boolean:
    - name: httpd_can_network_connect
    - value: true
    - persist: true

/etc/pki/tls/private/{{ value }}.key:
  file.managed:
    - mode: 644
    - user: root
    - group: root
    - contents_pillar: {{ value }}_privatekey
    - require_in:
      - file: /etc/httpd/vhosts.d/{{ value }}.conf

{% endfor %}
