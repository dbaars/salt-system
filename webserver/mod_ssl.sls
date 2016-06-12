# Install mod_ssl for httpd

mod_ssl:
  pkg.installed:
    - name: mod_ssl
    - require:
      - pkg: httpd
    - watch_in:
      - module: apache-restart