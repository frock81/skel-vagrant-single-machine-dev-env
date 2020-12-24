Create in here a vaulted document named _secret-local.yml_ whith the following commands, from the ansible folder:

	$ cd $project_root_folder/ansible
	project_root_folder/ansible$ ansible-vault create --encrypt-vault-id=sudo group_vars/all/secret-local.yml

This file is ignored by the version control (see .gitignore in the project root folder).