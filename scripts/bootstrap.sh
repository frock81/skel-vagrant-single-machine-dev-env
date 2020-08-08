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

# FIXME: this seems to be ineffective since the conditional evaluates
# to false for the first time.
# Use recent packages.
# if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -1440)" ]; then
#   sudo apt update --fix-missing && apt -yq upgrade
# fi

# FIXME: this works because the box comes with python3 installed. A
# better approach would be to inspect lists directory. The first time
# a Ubuntu box run there is no list for universe or multiverse. As a
# note, I inspected these files but they all have updated modification
# time:
#
#   - /var/lib/apt/periodic/update-success-stamp
#   - /var/cache/apt/pkgcache.bin
#
# reference command: `ll /var/lib/apt/lists/ | grep -E 'univers|multiv'`
# Also, it is important to review the necessity of python installation.
# The apt update is necessary since some packages will not be available
# without that.
#
# In the first vagrant up, python wont be installed. We use this characteristic
# # to update apt sources file.
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
