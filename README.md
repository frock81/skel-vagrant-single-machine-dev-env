# Skel - Single

Skel for a vagrant single machine development environment.

Steps:

1. Create file `~/.ansible/vault_pass_insecure` and put a generic pass in it
1. Exec `direnv allow`
1. Provision ip address at `/etc/hosts` in 192.168.4.0 network.
1. Update `Vagrantfile` with `project_name` and `ip_address`
1. Update `provision/hosts`
1. Update file `provision/group_vars/project_name.yml`
1. Update `provision/requirements.yml`
1. Update `provision/playbook.yml`