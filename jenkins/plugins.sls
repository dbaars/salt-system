include:
  - jenkins

{% set cli_path = '/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar' %}
{% set master_url = 'http://testvm3.niwa.local:8080' %}
{% set sshkey = '/root/.ssh/id_rsa' %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd) -%}
{{ ' '.join(['java', '-jar', cli_path, '-s', master_url, '-i', sshkey, cmd]) }} {{ ' '.join(varargs) }}
{%- endmacro -%}

{% set jenkinsplugins = salt['pillar.get']('jenkinsplugins') %}
{% for plugin in jenkinsplugins.split(',') %}

jenkins_install_plugin_{{ plugin }}:
  cmd.run:
    - unless: {{ jenkins_cli('list-plugins') }} | grep {{ plugin }}
    - name: {{ jenkins_cli('install-plugin', plugin) }}
    - timeout: 120
    - require:
      - service: jenkins
      - cmd: jenkins_responding
    - watch_in:
      - cmd: restart_jenkins

{% endfor %}
