# First lets make sure salt-minion is installed
# The below also restarts salt-minion if the file /etc/salt/minion is changed
salt-minion:
  pkg.installed: []
  service.running:
    - watch:
      - file: /etc/salt/minion
    - require:
      - pkg: salt-minion

# We want to manage the /etc/salt/minion file
/etc/salt/minion:
  file.managed:
    - source: salt://salt-minion/minion.template
    - template: jinja
    - mode: 640
    - user: root
    - group: root
