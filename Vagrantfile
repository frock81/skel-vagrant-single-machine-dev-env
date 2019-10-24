# -*- mode: ruby -*-
# vi: set ft=ruby :

# Project Name
$project_name = "project-name"

# Check /etc/hosts and provision one ip
$ip_address = "192.168.4."

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
  config.ssh.private_key_path = "./insecure_private_key"
  config.vm.box = "ubuntu/bionic64"
  config.vm.synced_folder "src", "/var/www/html",
    mount_options: ["dmode=777,fmode=777"]
  config.vm.define $project_name do |i|
    i.vm.provider "virtualbox" do |v|
      v.name = $project_name
      v.memory = 512
      v.cpus = 1
    end
    i.vm.hostname = $project_name
    i.vm.network "private_network", ip: $ip_address
  end
  config.vm.provision "shell", inline: $set_environment_variables, run: "always"
  # Experiencing some bug when installing ansible via Vagrant.
  # Also, install ansible via Vagrant is very slow.
  config.vm.provision "shell", inline: 'bash -c "test -e /usr/bin/pip || \
    apt-get update && apt-get install -qy python-pip"'
  config.vm.provision "shell", inline: 'bash -c "test -e /usr/bin/ansible || \
    pip install \'ansible==2.7.14\'"'
  config.vm.provision "shell", inline: "ansible-galaxy install --force \
    -r /vagrant/provision/requirements.yml \
    -p /vagrant/provision/roles"
  config.vm.provision "ansible_local" do |ansible|
      ansible.install = false
      # ansible.install_mode = "pip"
      # ansible.version = "2.7.10"
      ansible.provisioning_path = "/vagrant/provision"
      ansible.playbook = "playbook.yml"
      ansible.inventory_path = "hosts"
      ansible.become = true
      ansible.limit = "all"
      ansible.vault_password_file = ".vault_pass-local.txt"
      ansible.tags = ENV['ANSIBLE_TAGS']
      ansible.verbose = ENV['ANSIBLE_VERBOSE']
  end
end
