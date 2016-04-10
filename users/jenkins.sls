jenkins:
  group.present:
    - name: jenkins
<<<<<<< HEAD
    - gid: 5000
  user.present:
    - fullname: Jenkins CI
    - shell: /bin/bash
    - uid: 5000
    - gid: 5000
    - groups:
      - wheel
=======
    - gid: 1001
  user.present:
    - fullname: Jenkins CI
    - shell: /bin/bash
    - gid: 5000
    - groups:
      - wheel
      - jenkins
>>>>>>> refs/remotes/origin/test
    - empty_password: True
  ssh_auth.present:
    - user: jenkins
    - source: salt://ssh_keys/jenkins_id_rsa.pub
    - config: ".ssh/authorized_keys"

