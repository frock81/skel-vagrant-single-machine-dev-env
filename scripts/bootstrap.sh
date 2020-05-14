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

# Use recent packages.
if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -1440)" ]; then
  sudo apt update --fix-missing && apt -yq upgrade
fi

# In the first vagrant up, python wont be installed. We use this characteristic
# to update apt sources file.
if ! test -e /usr/bin/python; then
  sudo sed -i 's#http://archive.ubuntu.com#http://br.archive.ubuntu.com#g' \
    /etc/apt/sources.list
  echo "Updating packages list"
  sudo apt update
  sudo echo "Installing python."
  apt install -yq python-minimal python-pip
fi

# Install Ansible via Python PIP.
echo "Installing Ansible via PIP"
test -e /usr/bin/ansible-galaxy || sudo pip install ansible

# Install required roles.
if [ -r "$ANSIBLE_PATH/requirements.yml" ]; then
  echo "Installing required roles."
  ansible-galaxy install \
    -r $ANSIBLE_PATH/requirements.yml \
    -p $ANSIBLE_PATH/roles \
    --ignore-errors \
    --ignore-certs
fi
