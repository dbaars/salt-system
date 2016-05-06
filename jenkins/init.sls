Install Java for Jenkins:
  pkg.installed:
    - pkgs: 
      - java

Install Jenkins:
  pkg.installed:
    - pkg: jenkins
  service.running:
    - name: jenkins
    - require:
      - pkg: jenkins
  require:
    - pkg: java

