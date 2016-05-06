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
      - pkgs: 
        - jenkins
  require:
    - pkg: java

