#!/usr/bin/env bash

ansible-playbook --inventory-file=ansible/inventories/dev ansible/playbook.yml

ansible odoo01 --inventory-file=ansible/inventories/dev -m ping -vvvv

# with ansible.cfg
# ansible odoo01 -m ping -vvvv
# ansible-playbook odoo01 ansible/playbook.yml
