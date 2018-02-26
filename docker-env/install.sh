#!/bin/bash
set -ex

apt-get update
apt-get install -y devscripts gdebi-core mc sudo bindfs build-essential python \
	ccache debhelper quilt

echo 'alias ls="ls --color -Fh"' >> /etc/bash.bashrc
echo 'alias dir="ls -l"' >> /etc/bash.bashrc
echo 'app ALL=(root) NOPASSWD:ALL' > /etc/sudoers.d/app
chmod 440 /etc/sudoers.d/app

addgroup --gid 1000 app
adduser --uid 1000 --gid 1000 --disabled-password app
usermod -L app

cp /netdata_ubuntu_build/inithostmount.sh /sbin/inithostmount

rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*
rm -rf /netdata_ubuntu_build
