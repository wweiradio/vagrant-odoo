# -*- mode: ruby -*-
# vi: set ft=ruby :
# ~/VirtualBox VMs
# Vagrant_tempalte 

Vagrant.configure("2") do |config|

    #############################################################
    # Local Virtual box Provider
    #############################################################
    #config.vm.provider :virtualbox do |node_config|

    # config.ssh.username = "vagrant"
    # config.ssh.password = "vagrant"
    config.vm.network :forwarded_port, host: 33060, guest: 3306
    config.vm.network :private_network, ip: "192.168.13.37"


    config.vm.define "odoo01" do |node_config|

        node_config.vm.provider "virtualbox" do |vb|
           vb.name="odoo01"
           vb.memory=4096 
	       vb.cpus = 2
	       vb.gui = false # whether need to show the gui.
        end


        node_config.bindfs.default_options = {
            force_user:   'ubuntu', #16. LTS has ubuntu as the default login.
            force_group:  'ubuntu',
            perms:        'u=rwX:g=rD:o=rD'
        }

	    node_config.vm.hostname ="odoo01"
        node_config.vm.box = "ubuntu/xenial64"

        node_config.ssh.forward_x11 = true
        #node_config.name = "odoo.app"
        #node_config.customize ["modifyvm", :id, "--memory", 1024]
        config.ssh.forward_agent = true  # for checking out a remote Git repository over SSH,
        config.vm.synced_folder "./", "/ubuntu", type: "nfs"
       # node_config.bindfs.bind_folder  "/ubuntu", "/ubuntu", create_as_user: true
        node_config.bindfs.bind_folder  "/ubuntu", "/home/ubuntu/nfs"
        #node_config.vm.provision :shell, path: "increase_swap.sh"

    end

    #############################################################
    # Ansible provisioning (you need to have ansible installed)
    #############################################################


    #config.vm.provision "ansible" do |ansible|
    #    ansible.playbook = "ansible/playbook.yml"
    #    ansible.inventory_path = "ansible/inventories/dev"
    #    ansible.limit = 'all'
    #end
    
end
