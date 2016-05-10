# Open firewall port for http in the public zone
# https://docs.saltstack.com/en/latest/ref/states/all/salt.states.firewalld.html

public_10340:
  firewalld.present:
    - name: public
    - ports:
      - 10340/tcp

# What this means is that the service.running state will look for changes to the firewalld.present state 
# and restart firewalld if changes occur

firewalld_check_http:
  service.running:
    - name: firewalld
    - watch:
      - firewalld: public