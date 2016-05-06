Install Java for Jenkins:
  pkg.installed:
    - pkgs: java

Install Jenkins:
  pkg.installed: []
  service.running:
    - name: jenkins
    - require:
      - pkg: jenkins
  require:
    - pkg: java

