include:
  - java

Create swarm directory:
  file.directory:
    - name: /opt/swarm
    - user: root
    - group: root
    - dir_mode: 700

/opt/swarm/swarm-client-latest.jar:
  file.managed:
    - source: salt://jenkins/slave/files/swarm-client-latest.jar
    - template: jinja
    - mode: 600
    - user: root
    - group: root
    - require:
      - file: /opt/swarm

swarm.service:
  file.managed:
    - name: /etc/systemd/system/swarm.service
    - source: salt://jenkins/slave/files/swarm.service.template
    - template: jinja
    - mode: 600
    - user: root
    - group: root
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: /etc/systemd/system/swarm.service
  service.running:
    - enable: true
    - require:
      - file: swarm.service