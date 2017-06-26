# -*- mode: ruby -*-
# vi: set ft=ruby :
# ~/VirtualBox VMs
# Vagrant_tempalte 
# the passwd for ubuntu: 1

Vagrant.configure("2") do |config|

    #############################################################
    # Local Virtual box Provider
    #############################################################
    #config.vm.provider :virtualbox do |node_config|

    # config.ssh.username = "vagrant"
    # config.ssh.password = "vagrant"
    config.vm.network :forwarded_port, host: 33061, guest: 3306
    #access host 8080 will forward to guest 80
    config.vm.network "forwarded_port", guest: 80, host: 8081
    #access to host 8443 will forward to geuest 443
    config.vm.network "forwarded_port", guest: 443, host: 9443
    config.vm.network :private_network, ip: "192.168.13.38"


    config.vm.define "botman" do |node_config|

        node_config.vm.provider "virtualbox" do |vb|
           vb.name="botman"
           vb.memory=4096 
	   vb.cpus = 2
	   vb.gui = false # whether need to show the gui.
        end


        node_config.bindfs.default_options = {
            force_user:   'ubuntu', #16. LTS has ubuntu as the default login.
            force_group:  'ubuntu',
            perms:        'u=rwX:g=rD:o=rD'
        }

	node_config.vm.hostname ="botman"
        node_config.vm.box = "ubuntu/xenial64"

        node_config.ssh.forward_x11 = true
        #node_config.name = "odoo.app"
        #node_config.customize ["modifyvm", :id, "--memory", 1024]
        config.ssh.forward_agent = true  # for checking out a remote Git repository over SSH,
        config.vm.synced_folder "./", "/ubuntu", type: "nfs"
        node_config.bindfs.bind_folder  "/ubuntu", "/home/ubuntu/nfs"

        config.vm.synced_folder "/home/cason/src/projects/iibold", "/ubuntu2", type: "nfs"
        node_config.bindfs.bind_folder  "/ubuntu2", "/home/ubuntu/iibold"
	
        #node_config.vm.provision :shell, path: "increase_swap.sh"


        #############################################################
        # Ansible provisioning (you need to have ansible installed)
        # to run the following provisinong
        # vagrant provision
        # this part can also be put into config section for all hosts?
        #############################################################

        node_config.vm.provision "ansible" do |ansible|
            ansible.playbook = "ansible/playbook.yml"
            ansible.inventory_path = "ansible/inventories/dev"
            ansible.limit = 'all'
        end

    end


end
