#!/bin/bash

echo '* libraries/restart-without-asking boolean true' \
  | debconf-set-selections
if [ -z "$(find /var/cache/apt/pkgcache.bin -mmin -1440)" ]; then
  apt-get update --fix-missing && apt-get -yq upgrade
fi
test -e /usr/bin/python || apt-get install -yq python-minimal
test -e /usr/bin/pip || apt-get install -yq python-pip
test -e /usr/bin/ansible || pip install ansible==2.7.14
ansible-galaxy install \
    -r /vagrant/provision/requirements.yml \
    -p /vagrant/provision/roles
