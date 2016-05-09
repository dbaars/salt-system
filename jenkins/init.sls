include:
  - users.jenkins

{% set cli_path = '/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar' %}
{% set master_url = 'http://testvm3.niwa.local:8080' %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd) -%}
{{ ' '.join(['java', '-jar', cli_path, '-s', master_url, cmd]) }} {{ ' '.join(varargs) }}
{%- endmacro -%}

java-1.8.0-openjdk:
  pkg.installed: []

jenkins:
  pkg.installed: []
  file.managed:
    - name: /etc/sysconfig/jenkins
    - source: salt://jenkins/jenkins.sysconfig.template
    - template: jinja
    - mode: 600
    - user: root
    - group: root
  file.managed:
    - name: /var/lib/jenkins/config.xml
    - source: salt://jenkins/config.xml.template
    - template: jinja
    - mode: 640
    - user: jenkins
    - group: jenkins
  service.running:
    - name: jenkins
    - Enable: True
    - require:
      - pkg: jenkins
  require:
    - pkg: java-1.8.0-openjdk
    - sls: users.jenkins

jenkins_install_AD_plugin:
  cmd.run:
    - unless: {{ jenkins_cli('list-plugins') }} | grep active-directory
    - name: {{ jenkins_cli('install-plugin', 'active-directory') }}
    - timeout: 120
    - require:
      - service: jenkins
      - cmd: jenkins_responding
    - watch_in:
      - cmd: restart_jenkins

restart_jenkins:
  cmd.wait:
    - name: {{ jenkins_cli('safe-restart') }}
    - require:
      - cmd: jenkins_responding

jenkins_responding:
  cmd.wait:
    - name: "until {{ jenkins_cli('who-am-i') }}; do sleep 1; done"
    - timeout: 120