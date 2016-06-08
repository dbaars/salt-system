# The below adds the zjenkins user to the system under /home/zjenkins

Add zjenkins user:
  user.present:
    - name: zjenkins
    - shell: /bin/bash