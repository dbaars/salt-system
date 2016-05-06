jenkins:
  pkg.installed: []
  service.running:
    - name: jenkins
    - require:
      - pkg: jenkins
