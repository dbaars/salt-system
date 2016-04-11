# First lets make sure NTP is installed
ntp:
  pkg.installed: []
  service.running:
    - name: ntpd
    - require:
      - pkg: ntp

# We want to manage the /etc/ntp.conf file
/etc/ntp.conf:
  file.managed:
    - source: salt://ntp/ntp.conf.template
    - template: jinja
    - mode: 644
    - user: root
    - group: root
