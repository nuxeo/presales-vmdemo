#!/bin/bash

add-apt-repository universe
add-apt-repository multiverse

# Increase open files limit
echo '*       soft    nofile      4096' >> /etc/security/limits.conf
echo '*       hard    nofile      8192' >> /etc/security/limits.conf

# Create nuxeo user - UID 900 comes from the docker image
groupadd -g 900 nuxeo
useradd -m -g 900 -G ubuntu -u 900 nuxeo

# Upgrade packages and install apache, ssh, ...
export DEBIAN_FRONTEND=noninteractive
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
apt-get update
apt-get -q -y upgrade
apt-get -q -y install apache2 apt-transport-https openssh-server openssh-client vim jq git \
                      ca-certificates curl software-properties-common python3-pip figlet \
                      atop htop ctop make

#Additional modules and config for apache                      
a2enmod proxy proxy_http rewrite ssl headers
echo "Please wait a few minutes for you instance installation to complete" > /var/www/html/index.html

# Install latest aws cli using pip
pip3 install -q awscli --upgrade
export PATH=$PATH:~/.local/bin/

# Install docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get -q -y remove docker docker-engine docker.io
apt-get -q -y install docker-ce
pip3 install -q --system docker-compose
usermod -aG docker ubuntu

# Install Certbot
snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

apt-get -y clean
