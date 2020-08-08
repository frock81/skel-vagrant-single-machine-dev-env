# Skel - Single

Skel for a vagrant single machine development environment.

## Preparation

Clone the skel project, rename the cloned directory to the name of your project and cd to the project directory

    $ git clone https://github.com/frock81/skel-vagrant-single-machine-dev-env.git
    $ mv skel-vagrant-single-machine-dev-env <your-project-name>
    $ cd <your-project-name>

Steps:

1. Exec `direnv allow`
1. Provision ip address at `/etc/hosts` in 192.168.4.0 network
1. Update `Vagrantfile` with node names and ip addresses
1. Update `ansible/hosts-dev.ini` with node names and ip addresses (use hosts-prod.ini for production hosts)
1. Update `ansible/requirements.yml` (don't put submodules roles in requirements)
1. Update `ansible/playbook.yml` (and related playbooks like common.yml and dev-only.yml)
1. Create secrets (see section named _Secrets_)

Optional steps:

- Put directive config.vm.synced_folder in Vagrantfile for web server projects.
- Uncomment directive v.customize in Vagrantfile if you want to disable VT-x to use with KVM.
- Update config.vm.box in Vagrantfile (defaults to ubuntu/bionic64)
- Uncoment disk related lines to add more disks in Vagrantfile.

## Secrets

Secrets files to be created:

1. _~/.ansible_secret/vault_pass_insecure_ (relative to the home folder)
1. _~/.ansible_secret/vault_pass_sudo_ (to store sudo password for production)
1. _./ansible/vault_pass_prod_ (relative to the project folder to store sudo password for production)

Substitute the passwords accordingly.

```
    $ mkdir ~/.ansible_secret
    $ echo 'DEVELOPMENTPASSWORD' > ~/.ansible_secret/vault_pass_insecure
    $ echo 'RANDOMPASSWORD' > ~/.ansible_secret/vault_pass_sudo
    $ echo 'PRODUCTIONPASSWORD' > ansible/.vault_pass_prod
```

If you want different secrets edit _ansible.cfg_ and change `vault_identity_list` to match your setup. Also modify Vagrantfile as needed (`~/.ansible_secret` synced folder).

The file _vault_pass_insecure_ is used for development and shared between projects, so, as the name suggests, it is not secure to use it in production. It may be changed to a project specific secret located in the ansible project directory.

The secret file _vault_pass_sudo_ is used to store the variable `ansible_become_pass` with the sudo password to ease password typing. I used to put my development files in Dropbox/Google drive folder. In order to not store my sudo password I vaulted it. As such I put the key away from the vault (in _~/.ansible_secret_). The same way as the _vault_pass_insecure_, create a file with a random password in it (it does not need to be remembered as if it is deleted of forgotten another one can be generated). This step is optional, but if you want to use it run:

    $ cd ansible
    $ mkdir -p group_vars/all
    $ ansible-vault create --encrypt-vault-id=sudo group_vars/all/secret-local.yml

The file _secret-local.yml_, **should not** be put in version controle, but if it is by mistake, at least it is encrypted and your peers from the project won't have the password (different from _vault_pass_insecure_ and probably _.vault_pass_prod_).

After setting-up secrets make sure to uncomment the directive `vault_identity_list` and remove the current directive without the `sudo` and `prod` vaults.

## Running

    $ vagrant up
