# -*- mode: ruby -*-
# vi: set ft=ruby :

# Project Name
$project_name = "project-name"

# Check /etc/hosts and provision one ip
$ip_address = "192.168.4.254"

# Sets guest environment variables.
# @see https://github.com/hashicorp/vagrant/issues/7015
$set_environment_variables = <<SCRIPT
tee "/etc/profile.d/myvars.sh" > "/dev/null" <<EOF
# Ansible environment variables.
export ANSIBLE_RETRY_FILES_ENABLED=0
EOF
SCRIPT

Vagrant.configure("2") do |config|
  config.ssh.insert_key = false
  config.ssh.private_key_path = "./ansible/insecure_private_key"
  config.vm.box = "ubuntu/bionic64"
  # Uncomment in web server projects
  # config.vm.synced_folder "src", "/var/www/html",
  #   mount_options: ["dmode=777,fmode=777"]
  config.vm.define $project_name do |i|
    i.vm.provider "virtualbox" do |v|
      v.name = $project_name
      v.memory = 512
      v.cpus = 1
      # Uncomment if you want to disable VT-x to use with KVM.
      # v.customize ["modifyvm", :id, "--hwvirtex", "off"]
    end
    i.vm.hostname = $project_name
    i.vm.network "private_network", ip: $ip_address
  end
#-------------------------------------------------------------------------------
# Provision
#-------------------------------------------------------------------------------
  config.vm.synced_folder "~/.ansible", "/tmp/ansible"
  config.vm.synced_folder "./ansible", "/etc/ansible"
  config.vm.provision "shell", inline: $set_environment_variables, run: "always"
  config.vm.provision "shell", path: "scripts/bootstrap.sh"
  config.vm.provision "ansible_local" do |ansible|
      ansible.install = false
      # ansible.install_mode = "pip"
      # ansible.version = "2.7.10"
      ansible.provisioning_path = "/etc/ansible"
      ansible.playbook = "playbook.yml"
      ansible.inventory_path = "hosts"
      ansible.become = true
      ansible.limit = "all"
      ansible.vault_password_file = "/tmp/ansible/vault_pass_insecure"
      ansible.limit = (defined? (ENV['ANSIBLE_LIMIT'])) \
        ? ENV['ANSIBLE_LIMIT'] : "all"
      ansible.tags = ENV['ANSIBLE_TAGS']
      ansible.verbose = ENV['ANSIBLE_VERBOSE']
  end
end
