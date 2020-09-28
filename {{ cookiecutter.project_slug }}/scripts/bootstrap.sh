#!/bin/bash

# Commands to be executed at the provisioner host (the one that will execute the
# ansible-playbook command)

# SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
ANSIBLE_PATH=/etc/ansible

# To fix dpkg error in provisioning.
export DEBIAN_FRONTEND=noninteractive

# Avoid prompting questions.
echo '* libraries/restart-without-asking boolean true' \
  | sudo debconf-set-selections

# Some packages may be missing because the new box doesn't have
# repositories list, although it is configured in the sources.
if ! $(ls -lh /var/lib/apt/lists | grep -E "universe|multiverse" &> /dev/null); then
  sudo apt-get update --fix-missing && apt-get -yq upgrade
fi

if ! $(dpkg -s python3-pip &> /dev/null); then
  sudo apt-get install -y python3-pip
fi

# Install Ansible via Python PIP.
if ! test -e /usr/local/bin/ansible-galaxy; then
  echo "Installing Ansible via Pip"
  sudo pip3 install ansible
fi

# Install required roles.
if [ -r "$ANSIBLE_PATH/requirements.yml" ]; then
  echo "Installing required roles."
  ansible-galaxy install \
    -r $ANSIBLE_PATH/requirements.yml \
    -p $ANSIBLE_PATH/roles \
    --ignore-errors \
    --ignore-certs
fi
