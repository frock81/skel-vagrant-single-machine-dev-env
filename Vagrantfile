# -*- mode: ruby -*-
# vi: set ft=ruby :

# The box to be used by Vagrant.
VAGRANT_BOX = "ubuntu/bionic64"

# Number of CPUs allocated to the virtual machine instances.
VM_CPUS = 2

# Total of RAM memory in megabytes allocated to the vm instances.
VM_MEMORY = 2048

# The prefix for the hostname and virtual machine name.
INSTANCE_NAME = "foo"

# The IP address.
IP_ADDRESS = "192.168.4.253"

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
  config.vm.box = VAGRANT_BOX

  config.vm.define "#{INSTANCE_NAME}" do |machine|
    machine.vm.provider "virtualbox" do |vbox|
      vbox.name = "#{INSTANCE_NAME}"
      # XXX: move memory and cpus outside the loop.
      vbox.memory = VM_MEMORY
      vbox.cpus = VM_CPUS

      # Uncomment if you want to disable VT-x to use with KVM.
      # vbox.customize ["modifyvm", :id, "--hwvirtex", "off"]

      # Uncomment to enable nested virtualization.
      # vbox.customize ["modifyvm", :id, "--nested-hw-virt", "on"]

      # Uncoment to add more disks. See vboxmanage documentation.
      # disk_size_in_mb = 128
      # disks_total = 4
      # for j in 1..disks_total
      #   file_to_disk = File.join(VAGRANT_ROOT, '.vagrant', "#{INSTANCE_NAME}-#{i}-disk-#{j}.vdi")
      #   unless File.exist?(file_to_disk)
      #     vbox.customize ['createmedium', 'disk',
      #       '--filename', file_to_disk,
      #       '--size', disk_size_in_mb,
      #       '--variant', 'Standard']
      #   end
      #   vbox.customize ['storageattach', :id,
      #     '--storagectl', 'SCSI',
      #     '--port', 2 + j - 1,
      #     '--device', 0,
      #     '--type', 'hdd',
      #     '--medium', file_to_disk]
      # end
    end
    machine.vm.hostname = "#{INSTANCE_NAME}"
    machine.vm.network "private_network", ip: "#{IP_ADDRESS}"

    # Vault passwords in home dir in order to not leave the key and the
    # lock together (useful for projects inside Dropbox/Gdrive).
    machine.vm.synced_folder "~/.ansible_secret", \
      "/home/vagrant/.ansible_secret"
    machine.vm.synced_folder "ansible", "/etc/ansible"
    machine.vm.provision "shell", inline: $set_environment_variables, \
      run: "always"
    machine.vm.provision "shell", path: "scripts/bootstrap.sh"
    machine.vm.provision "ansible_local" do |ansible|
      ansible.compatibility_mode = "2.0"
      ansible.install = false
      ansible.provisioning_path = "/etc/ansible"
      ansible.playbook = ENV["ANSIBLE_PLAYBOOK"] ? ENV["ANSIBLE_PLAYBOOK"] \
        : "playbook.yml"
      ansible.inventory_path = "hosts-dev.ini"
      ansible.limit = ENV['ANSIBLE_LIMIT'] ? ENV['ANSIBLE_LIMIT'] : "all"
      ansible.vault_password_file = "/home/vagrant/.ansible_secret/" +
        "vault_pass_insecure"
      ansible.tags = ENV['ANSIBLE_TAGS']
      ansible.verbose = ENV['ANSIBLE_VERBOSE']
    end
  end
end
