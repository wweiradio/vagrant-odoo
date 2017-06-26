#!/usr/bin/env bash

#vagrant provision 
#ansible-playbook --inventory-file=ansible/inventories/dev ansible/playbook.yml

#ansible odoo01 --inventory-file=ansible/inventories/dev -m ping -vvvv

# with ansible.cfg
# ansible odoo01 -m ping -vvvv
ansible-playbook -i ansible/inventories/dev ansible/playbook.yml
#ansible-playbook -i lamp_simple/hosts lamp_simple/site.yml
