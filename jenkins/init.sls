include:
  - users.jenkins

java-1.8.0-openjdk:
  pkg.installed: []

jenkins:
  pkg.installed: []
  file.managed:
    - name: /etc/sysconfig/jenkins
    - source: salt://jenkins/jenkins.sysconfig.template
    - template: jinja
    - mode: 600
    - user: root
    - group: root
  service.running:
    - name: jenkins
    - require:
      - pkg: jenkins
  require:
    - pkg: java-1.8.0-openjdk
    - sls: users.jenkins


  
