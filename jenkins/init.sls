include:
  - users.jenkins

{% set cli_path = '/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar' %}
{% set master_url = 'http://testvm3.niwa.local:8080' %}
{% set zsaltuserpw = {{ pillar['zsaltuserpw'] }} %}

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
  service.running:
    - name: jenkins
    - Enable: True
    - require:
      - pkg: jenkins
  require:
    - pkg: java-1.8.0-openjdk
    - sls: users.jenkins

/var/lib/jenkins/config.xml:
  file.managed:
    - source: salt://jenkins/config.xml.template
    - template: jinja
    - mode: 640
    - user: jenkins
    - group: jenkins

restart_jenkins:
  cmd.wait:
    - name: {{ jenkins_cli('safe-restart') }}
    - require:
      - cmd: jenkins_responding

jenkins_responding:
  cmd.wait:
    - name: "until {{ jenkins_cli('who-am-i') }}; do sleep 1; done"
    - timeout: 120
    - require:
      - cmd: jenkins_login

jenkins_login:
  cmd.run:
    - unless: {{ jenkins_cli('who-am-i') }} | grep zsaltuser
    - name: {{ jenkins_cli('login', '--username=zsaltuser', '--password=', zsaltuserpw) }}
    - timout: 120
    - require:
      - service: jenkins