Install Java for Jenkins:
  pkg.installed:
    - pkgs: 
      - java-1.8.0-openjdk

Install Jenkins:
  pkg.installed:
    - pkgs: 
      - jenkins
  service.running:
    - name: jenkins
    - require:
      - pkg: jenkins
  require:
    - pkg: java

