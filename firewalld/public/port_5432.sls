# Open firewall for port 5432 in the public zone
# For Postgresql normally

{% for key, ip_app_server in pillar.items() if key.startswith('firewalld_open_to') %}
public_fw_allow_{{ ip_app_server }}_to_port_5432:
  zones:
    public:
      rich_rules:
        - family: ipv4
          source:
              address: {{ ip_app_server }}/24
              port: 5432
              protocol: tcp
          accept: true

firewalld_check_public_{{ ip_app_server }}:
  service.running:
    - name: firewalld
    - watch:
      - firewalld: public
