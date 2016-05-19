include:
  - java.jdk
  - subversion
  - git
  - maven
  - ant
  - php.php-unit
  - nodejs
  - npm
  - composer

Create swarm directory:
  file.directory:
    - name: /opt/swarm
    - user: root
    - group: users
    - dir_mode: 755

Create swarm working directory:
  file.directory:
    - name: /opt/swarm
    - user: zjenkins
    - group: unix-users
    - dir_mode: 700

/opt/swarm/swarm-client-latest.jar:
  file.managed:
    - source: salt://jenkins/slave/files/swarm-client-latest.jar
    - mode: 644
    - user: root
    - group: users
    - require:
      - file: /opt/swarm

swarm.service:
  file.managed:
    - name: /etc/systemd/system/swarm.service
    - source: salt://jenkins/slave/files/swarm.service.template
    - template: jinja
    - mode: 644
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
