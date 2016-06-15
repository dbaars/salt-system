include:
  - users.jenkins
  - webserver
  - webserver.vhosts.revproxy_create
  - java

{% set cli_path = '/var/cache/jenkins/war/WEB-INF/jenkins-cli.jar' %}
{% set master_url = salt['pillar.get']('jenkinsurl') %}
{% set sshkey = '/root/.ssh/id_rsa' %}

{%- macro fmtarg(prefix, value)-%}
{{ (prefix + ' ' + value) if value else '' }}
{%- endmacro -%}
{%- macro jenkins_cli(cmd) -%}
{{ ' '.join(['java', '-jar', cli_path, '-s', master_url, '-i', sshkey, cmd]) }} {{ ' '.join(varargs) }}
{%- endmacro -%}

# Initial configuration requirements:
# 1. We need to get a private key onto the box so Salt can run jenkins-cli commands
# 2. If pillar localrevproxy_jenkins is defined, add the certificate and certificate key
# 3. Configure SSSD with the Jenkins groups
# 4. Install Java

MakeRootSSHdirforJenkins:
  file.directory:
    - name: /root/.ssh
    - user: root
    - group: root
    - dir_mode: 700

/root/.ssh/id_rsa:
  file.managed:
    - mode: 600
    - user: root
    - group: root
    - contents_pillar: jenkinskey
    - require:
      - file: /root/.ssh

# Note: This SSSD service check should be moved to a real SSSD state file when it exists
sssd_service_check:
  service.running:
    - name: sssd

# This checks for a line starting with "simple_allow_groups" and if that line DOES NOT contain
# jenkins-users,jenkins-admins it adds those to groups to the end of the line
Add_jenkins_groups_to_sssd:
  file.replace:
    - name: /etc/sssd/sssd.conf
    - pattern: '(^(?!.*jenkins-users,jenkins-admins).*simple_allow_groups.*$)'
    - repl: '\1,jenkins-users,jenkins-admins'
    - watch_in:
      - service: sssd

# Install Jenkins
# Enable and start Jenkins
# Requires Java and the users.jenkins sls
# Jenkins requires execute privileges to a tmp directory. As our Kickstart disables exe to /tmp
# we need to create a directory where Jenkins can execute in
# This directory is then pointed to by the startup script /etc/sysconfig/jenkins
jenkins:
  pkg.installed: []
  file.directory:
    - name: /var/lib/jenkins/tmp
    - user: jenkins
    - group: jenkins
    - dir_mode: 700
    - require:
      - pkg: jenkins
  service.running:
    - name: jenkins
    - Enable: True
    - require:
      - pkg: jenkins
      - file: /etc/sysconfig/jenkins
      - file: /var/lib/jenkins/config.xml
  require:
    - pkg: java-1.8.0-openjdk
    - sls: users.jenkins

/etc/sysconfig/jenkins:
  file.managed:
    - name: /etc/sysconfig/jenkins
    - source: salt://jenkins/files/jenkins.sysconfig.template
    - template: jinja
    - mode: 600
    - user: root
    - group: root
    - watch_in:
      - cmd: restart_jenkins

# Manage the main configuration file for Jenkins
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

# Create the users directory and root user folder if it doesn't exist 
/var/lib/jenkins/users/root:
  file.directory:
    - user: jenkins
    - group: unix-users
    - dir_mode: 750
    - makedirs: True
    - require:
      - pkg: jenkins

# This file contains the root users public key, the private key was deployed above
# This allows jenkins-cli commands to be run by root
/var/lib/jenkins/users/root/config.xml:
  file.managed:
    - source: salt://jenkins/files/root_config.xml.template
    - template: jinja
    - mode: 640
    - user: jenkins
    - group: jenkins
    - require:
      - pkg: jenkins
      - file: /var/lib/jenkins/users/root

# Create the zjenkins user directory - this user is used by slaves to connect to jenkins
/var/lib/jenkins/users/zjenkins:
  file.directory:
    - user: jenkins
    - group: unix-users
    - dir_mode: 750
    - makedirs: True
    - require:
      - pkg: jenkins

# This file contains the zjenkins API key
# This allows jenkins slave servers to connect
/var/lib/jenkins/users/zjenkins/config.xml:
  file.managed:
    - source: salt://jenkins/files/zjenkins_config.xml.template
    - template: jinja
    - mode: 640
    - user: jenkins
    - group: unix-users
    - require:
      - pkg: jenkins
      - file: /var/lib/jenkins/users/zjenkins

# Use jenkins-cli to gracefully restart jenkins if required
# Check and waits for jenkins to respond first
restart_jenkins:
  cmd.wait:
    - name: {{ jenkins_cli('safe-restart') }}
    - require:
      - cmd: jenkins_responding

# Checks if Jenkins is responding, and if it isn't (because it might be busy) waits and retries every second for 120 seconds
jenkins_responding:
  cmd.wait:
    - name: "until {{ jenkins_cli('who-am-i') }}; do sleep 1; done"
    - timeout: 60
