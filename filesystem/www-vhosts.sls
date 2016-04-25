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
  module.run:
    - name: file.set_selinux_context
    - path: /srv/www
    - type: httpd_sys_content_t
    - unless: "stat -c %C /srv/www | grep 'httpd_sys_content_t'"

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
  module.run:
    - name: file.set_selinux_context
    - path: /srv/www/vhosts
    - type: httpd_sys_content_t
    - unless: "stat -c %C /srv/www/vhosts | grep 'httpd_sys_content_t'"

