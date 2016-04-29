# The below adds the Jenkins user to the system
# Note: The ssh key is stored on the file system /srv/salt rather than in github

Add Jenkins user and group:
  group.present:
    - name: jenkins
    - gid: 1001
  user.present:
    - name: jenkins
    - shell: /bin/bash
    - groups:
      - wheel
      - jenkins
    - empty_password: True

  ssh_auth.present:
    - user: jenkins
    - source: salt://ssh_keys/jenkins_id_rsa.pub
    - config: ".ssh/authorized_keys"

