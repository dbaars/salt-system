# Adds /srv/www and /srv/www/vhosts folders
# Assigns rights as specified

/srv/www/:
  file.directory:
    - user: apache
    - group: apache
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group

/srv/www/vhosts/:
  file.directory:
    - user: apache
    - group: apache
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
  acl.present:
    - acl_type: user
    - acl_name: jenkins
    - perms: rwx
    - recurse: True
