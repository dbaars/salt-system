jenkins:
  group.present:
    - name: jenkins
    - gid: 5000
  user.present:
    - fullname: Jenkins CI
    - shell: /bin/bash
    - gid: 5000
    - groups:
      - wheel
      - jenkins
    - empty_password: True
  ssh_auth.present:
    - user: jenkins
    - source: salt://ssh_keys/jenkins_id_rsa.pub
    - config: ".ssh/authorized_keys"

