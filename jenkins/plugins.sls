include:
  - jenkins

{% set jenkinsplugins = salt['pillar.get']('jenkinsplugins') %}
{% for plugin in jenkinsplugins.split(',') %}

jenkins_install_plugin_{{ plugin }}:
  cmd.run:
    - unless: {{ jenkins_cli('list-plugins') }} | grep {{ plugin }}
    - name: {{ jenkins_cli('install-plugin', plugin) }}
    - timeout: 120
    - require:
      - service: jenkins
#      - cmd: jenkins_updates_file
      - cmd: jenkins_responding
    - watch_in:
      - cmd: restart_jenkins

{% endfor %}
