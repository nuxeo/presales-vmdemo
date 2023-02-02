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
                      atop htop ctop make uuid

#Additional modules and config for apache                      
a2enmod proxy proxy_http rewrite ssl headers
echo "Please wait a few minutes for you instance installation to complete" > /var/www/html/index.html

# Install latest aws cli using pip
pip3 install -q awscli --upgrade
export PATH=$PATH:~/.local/bin/

# Install docker
apt-get -q -y remove docker docker-engine docker.io containerd runc
apt-get -q -y update
apt-get -q -y install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get -q -y update
apt-get -q -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
usermod -aG docker ubuntu

# Install Certbot
snap install core; snap refresh core
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot

apt-get -y clean
