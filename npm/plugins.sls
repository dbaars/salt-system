{% set npmplugins = salt['pillar.get']('npmplugins') %}
{% for plugin in npmplugins.split(',') %}

npm_install_plugin_{{ plugin }}:
  cmd.run:
    - unless:  npm list -g less | grep {{ plugin }}
    - name: npm -g install {{ plugin }}
    - timeout: 120
    - require:
      - pkg: npm

{% endfor %}