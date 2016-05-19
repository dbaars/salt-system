include:
  - npm

{% set npmplugins = salt['pillar.get']('npmplugins') %}
{% for plugin in npmplugins.split(',') %}

npm_install_plugin_{{ plugin }}:
  cmd.run:
    - unless:  npm -g list {{ plugin }} | grep {{ plugin }}
    - name: npm -g install {{ plugin }}
    - timeout: 120
    - require:
      - pkg: npm

npm_update_{{ plugin }}:
  cmd.run:
    - name: npm -g update {{ plugin }}
    - timeout: 120
    - require:
      - pkg: npm

{% endfor %}
