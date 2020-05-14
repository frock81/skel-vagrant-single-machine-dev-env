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

VAGRANT_ROOT = File.dirname(File.expand_path(__FILE__))

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

      # Uncoment to add more disks.
      # file_to_disk = File.join(VAGRANT_ROOT, '.vagrant', 'node1-disk1.vdi')
      # unless File.exist?(file_to_disk)
      #   vbox.customize ['createhd', '--filename', file_to_disk, '--size', 500 * 1024]
      # end
      # vbox.customize ['storageattach', :id, '--storagectl',
      #   'SCSI', '--port', 4, '--device', 0, '--type', 'hdd',
      #   '--medium', file_to_disk]
    end
    i.vm.hostname = $project_name
    i.vm.network "private_network", ip: $ip_address
  end
#-------------------------------------------------------------------------------
# Provision
#-------------------------------------------------------------------------------
  copnfig.vm.synced_folder "~/.ansible_secret", \
      "/home/vagrant/.ansible_secret"
  copnfig.vm.synced_folder "ansible", "/etc/ansible"
  config.vm.provision "shell", inline: $set_environment_variables, run: "always"
  config.vm.provision "shell", path: "scripts/bootstrap.sh"
  config.vm.provision "ansible_local" do |ansible|
    ansible.compatibility_mode = "2.0"
    ansible.install = false
    ansible.provisioning_path = "/etc/ansible"
    ansible.playbook = ENV["ANSIBLE_PLAYBOOK"] ? ENV["ANSIBLE_PLAYBOOK"] \
      : "playbook.yml"
    ansible.inventory_path = "hosts-dev.ini"
    ansible.become = true
    ansible.limit = ENV['ANSIBLE_LIMIT'] ? ENV['ANSIBLE_LIMIT'] : "all"
    ansible.vault_password_file = "/home/vagrant/.ansible_secret/vault_pass_insecure"
    ansible.tags = ENV['ANSIBLE_TAGS']
    ansible.verbose = ENV['ANSIBLE_VERBOSE']
  end
end
