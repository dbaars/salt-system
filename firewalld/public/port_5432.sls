# Open firewall for port 5432 in the public zone
# For Postgresql normally

public_http:
  firewalld.present:
    - name: public
    - ports:
      - 5432/tcp

# What this means is that the service.running state will look for changes to the firewalld.present state 
# and restart firewalld if changes occur

firewalld_check_http:
  service.running:
    - name: firewalld
    - watch:
      - firewalld: public