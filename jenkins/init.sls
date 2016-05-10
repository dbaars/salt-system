include:
  - users.jenkins

{% set cli_path = '/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar' %}
{% set master_url = salt['pillar.get']('jenkinsurl') %}
{% set sshkey = '/root/.ssh/id_rsa' %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd) -%}
{{ ' '.join(['java', '-jar', cli_path, '-s', master_url, '-i', sshkey, cmd]) }} {{ ' '.join(varargs) }}
{%- endmacro -%}


/root/.ssh/id_rsa:
  file.managed:
    - mode: 600
    - user: root
    - group: root
    - contents_pillar: jenkinskey

java-1.8.0-openjdk:
  pkg.installed: []

jenkins:
  pkg.installed: []
  file.managed:
    - name: /etc/sysconfig/jenkins
    - source: salt://jenkins/files/jenkins.sysconfig.template
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
    - source: salt://jenkins/files/config.xml.template
    - template: jinja
    - mode: 640
    - user: jenkins
    - group: jenkins
    - require:
      - pkg: jenkins
    - watch_in:
      - cmd: restart_jenkins

/var/lib/jenkins/tmp:
  file.directory:
    - user: jenkins
    - group: jenkins
    - dir_mode: 700
    - require:
      - pkg: jenkins

/var/lib/jenkins/users/root:
  file.directory:
    - user: jenkins
    - group: jenkins
    - dir_mode: 750
    - require:
      - pkg: jenkins

/var/lib/jenkins/users/root/config.xml:
  file.managed:
    - source: salt://jenkins/files/root_config.xml.template
    - template: jinja
    - mode: 640
    - user: jenkins
    - group: jenkins
    - require:
      - pkg: jenkins

restart_jenkins:
  cmd.wait:
    - name: {{ jenkins_cli('safe-restart') }}
    - require:
      - cmd: jenkins_responding

jenkins_responding:
  cmd.wait:
    - name: "until {{ jenkins_cli('who-am-i') }}; do sleep 1; done"
    - timeout: 120
