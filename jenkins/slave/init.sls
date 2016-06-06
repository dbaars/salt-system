include:
  - java.jdk
  - subversion
  - git
  - maven
  - ant
  - php.php-unit
  - nodejs
  - npm
  - npm.plugins
  - composer
  - rpm-build

Create swarm working directory:
  file.directory:
    - name: /opt/swarm
    - user: zjenkins
    - group: users
    - dir_mode: 700

/opt/swarm/swarm-client-latest.jar:
  file.managed:
    - source: salt://jenkins/slave/files/swarm-client-latest.jar
    - mode: 644
    - user: zjenkins
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
    - name: service.systemctl_restart
    - watch:
      - file: /etc/systemd/system/swarm.service
  service.running:
    - enable: true
    - require:
      - file: swarm.service
