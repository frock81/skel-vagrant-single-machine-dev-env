#!/bin/bash

# To fix dpkg error in provisioning
export DEBIAN_FRONTEND=noninteractive

echo '* libraries/restart-without-asking boolean true' \
  | debconf-set-selections

if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -1440)" ]; then
  apt-get update --fix-missing && apt-get -yq upgrade
fi

test -e /usr/bin/python || apt-get install -yq python-minimal
if ! test -e /usr/bin/pip; then
  apt-get update
  apt-get install -yq python-pip
fi
test -e /usr/bin/ansible-galaxy || pip install ansible
ansible-galaxy install \
    -r /vagrant/provision/requirements.yml \
    -p /vagrant/provision/roles \
    --ignore-errors
