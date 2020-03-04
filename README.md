# Skel - Single

Skel for a vagrant single machine development environment.

Steps:

1. Create file `~/.ansible/vault_pass_insecure` and put a generic pass in it
1. Exec `direnv allow`
1. Provision ip address at `/etc/hosts` in 192.168.4.0 network.
1. Update `Vagrantfile` with `project_name` and `ip_address`
1. Update `ansible/hosts`
1. Update file `ansible/group_vars/project_name.yml`
1. Update `ansible/requirements.yml`
1. Update `ansible/playbook.yml`

Other optional steps:

- Uncomment directive config.vm.synced_folder in Vagrantfile for web server projects.
- Uncomment directive v.customize in Vagrantfile if you want to disable VT-x to use with KVM.
- Uncomment python-mysqldb install in bootstrap.sh if ansible local provisioner uses mysql module.
- Update config.vm.box in VagrantFile (defaults to ubuntu/bionic64)
