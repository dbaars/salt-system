# Open firewall port for https in the public zone

public_https:
  firewalld.present:
    - name: public
    - services:
      - https

# What this means is that the service.running state will look for changes to the firewalld.present state 
# and restart firewalld if changes occur

firewalld:
  service.running:
    - watch:
      - firewalld: public