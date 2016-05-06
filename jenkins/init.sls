include:
  - users.jenkins

java-1.8.0-openjdk:
  pkg.installed: []

jenkins:
  pkg.installed: []
  file.replace:
    - name: /etc/sysconfig/jenkins
    - pattern: 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true"'
    - repl: 'JENKINS_JAVA_OPTIONS="-Djava.awt.headless=true -Djava.io.tmpdir=$JENKINS_HOME/tmp"'
  service.running:
    - name: jenkins
    - require:
      - pkg: jenkins
  require:
    - pkg: java-1.8.0-openjdk
    - sls: users.jenkins


  
