#!/bin/bash

# Installation can take time.
# You can tail -F /var/log/nev_install.log to see basic install progress
# You can tail -F /var/log/syslog to see the full startup and check for errors

# Start of installation script

echo "Nuxeo Presales Installation Script (NPIS): Starting [${STACK_ID}]" > ${INSTALL_LOG}

source /etc/profile.d/load_env.sh

# Variables for installation
INSTALL_LOG="/var/log/nev_install.log"

COMPOSE_REPO="https://github.com/nuxeo-sandbox/nuxeo-presales-nev"
COMPOSE_DIR="/home/ubuntu/nuxeo-presales-nev"

NEV_ENV="${COMPOSE_DIR}/.env"

# Check DNS Name
if [ -z "${DNS_NAME}" ]; then
  DNS_NAME=${STACK_ID}
  echo "Warning: DNS Name is not set, using stack id: ${STACK_ID}" | tee -a ${INSTALL_LOG}
fi

# Fully qualified domain name
FQDN="${DNS_NAME}.cloud.nuxeo.com"

# Set the hostname & domain
echo "${DNS_NAME}" > /etc/hostname
hostname ${DNS_NAME}
echo "Domains=cloud.nuxeo.com" >> /etc/systemd/resolved.conf

#== Install NEV Tooling ========================================================
echo "NPIS: Install NEV Tooling" | tee -a ${INSTALL_LOG}

# Make directories and clone compose stack
mkdir -p ${COMPOSE_DIR}
git clone ${COMPOSE_REPO} ${COMPOSE_DIR}

#== Install NEV ================================================================
echo "NPIS: Install NEV" | tee -a ${INSTALL_LOG}

# Home required by 'docker'
export HOME="/home/ubuntu"

# Get credentials for Docker Repository
aws secretsmanager get-secret-value --secret-id connect_shared_presales_credential --region us-west-2 > /root/creds.json

# Log in to docker
DOCKER_USER=$(jq -r '.SecretString|fromjson|.docker_presales_user' < /root/creds.json)
DOCKER_PASS=$(jq -r '.SecretString|fromjson|.docker_presales_pwd' < /root/creds.json)
echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin docker-arender.packages.nuxeo.com 2>&1 | tee -a ${INSTALL_LOG}

# Check if NUXEO_SECRET is a SecretsManager ARN
# If so, retrieve secret and set to NUXEO_SECRET
if [[ "$NUXEO_SECRET" == *"aws:secretsmanager"* ]]; then
  aws --region ${REGION} secretsmanager get-secret-value --secret-id ${NUXEO_SECRET} --output text | jq -r .password > /home/ubuntu/nxs
fi

# Set working environment
cat << EOF > ${NEV_ENV}
# NEV Version
NEV_VERSION=${NEV_VERSION}
# Nuxeo Server URL
NUXEO_URL=${NUXEO_URL}
# Nuxeo Server Oauth token
NUXEO_SECRET=${NUXEO_SECRET}
EOF

# Fix up permissions
rm -f /root/creds.json
chown -R ubuntu:ubuntu ${COMPOSE_DIR} ${HOME}/.docker

cd ${COMPOSE_DIR}

#  Pull images
echo "NPIS: Pulling images..." | tee -a ${INSTALL_LOG}
docker-compose --no-ansi pull | tee -a ${INSTALL_LOG}

if [[ "${AUTO_START}" == "true" ]]; then
  echo "NPIS: Start NEV..." | tee -a ${INSTALL_LOG}
  docker-compose --no-ansi up --detach --no-color 2>&1 | tee -a ${INSTALL_LOG}
fi

echo "NPIS: Install Misc." | tee -a ${INSTALL_LOG}
# Update some defaults
update-alternatives --set editor /usr/bin/vim.basic

# Configure reverse-proxy
echo "NPIS: Configure reverse-proxy" | tee -a ${INSTALL_LOG}

cat << EOF > /etc/apache2/sites-available/nev.conf
<VirtualHost _default_:80>
    ServerName  ${FQDN}
    CustomLog /var/log/apache2/nev_access.log combined
    ErrorLog /var/log/apache2/nev_error.log
    Redirect permanent / https://${FQDN}/
</VirtualHost>

<VirtualHost _default_:443 >

    ServerName  ${FQDN}

    CustomLog /var/log/apache2/nev_access.log combined
    ErrorLog /var/log/apache2/nev_error.log

    DocumentRoot /var/www

    ProxyRequests   Off
     <Proxy * >
        Order allow,deny
        Allow from all
     </Proxy>

    RewriteEngine   On

    ProxyPass           /            http://localhost:8080/
    ProxyPreserveHost   On

    RequestHeader set "X-Forwarded-Proto" expr=%{REQUEST_SCHEME}
    RequestHeader set "X-Forwarded-SSL" expr=%{HTTPS}

</VirtualHost>
EOF

a2enmod proxy proxy_http rewrite ssl headers
a2dissite 000-default
a2ensite nev

apache2ctl -k graceful

# Enable SSL certs
echo "NPIS: Enable Certbot Certificate" | tee -a ${INSTALL_LOG}
certbot -q --apache --redirect --hsts --uir --agree-tos -m wwpresalesdemos@hyland.com -d ${FQDN} | tee -a ${INSTALL_LOG}

echo "NPIS: Setup profile, ubuntu, etc." | tee -a ${INSTALL_LOG}

#set up ubuntu user
cat << EOF >> /home/ubuntu/.profile
export TERM="xterm-color"
export PS1='\[\e[0;33m\]\u\[\e[0m\]@\[\e[0;32m\]\h\[\e[0m\]:\[\e[0;34m\]\w\[\e[0m\]\$ '
export COMPOSE_DIR=${COMPOSE_DIR}
alias dir='ls -alFGh'
alias hs='history'
alias mytail='nevlogs'
alias mydu='du -sh */'

# Add stack management and QOL aliases
source ${COMPOSE_DIR}/aliases.sh

# Override some of the above for AWS usage
alias nev='make -e -f ${COMPOSE_DIR}/Makefile'

figlet $DNS_NAME.cloud.nuxeo.com
EOF

# Set up vim for ubuntu user
cat << EOF > /home/ubuntu/.vimrc
" Set the filetype based on the file's extension, but only if
" 'filetype' has not already been set
au BufRead,BufNewFile *.conf setfiletype conf
EOF

echo "NPIS: Complete" | tee -a ${INSTALL_LOG}
