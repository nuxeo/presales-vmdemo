#!/bin/bash

#### How to use this...
### In AWS:
## First, stop any instances using domain name you want.
## Then, stop the target EC2. This will get rid of its current DNS record.
## Then, update the dnsName tag on target EC2.
## Then, restart the target EC2.

## At this point, you can SSH into your target EC2 using the new FQDN;
## however, the services and conf files on the target EC2 are still
## using the old FQDN.

### In EC2:
## Run this script as root.
## It can be run with the new DNS name as an argument (e.g. sudo ./newDNS.sh myNewDNSname)
## 
## You will be prompted to input the old dnsName value and the new dnsName value.
## If the default values suggested by the script are correct, just press enter;
## otherwise, enter the correct values.
##
## It is good practice to delete the old certificate. You will be prompted to do so,
## but not forced.
##
## Here's what the script will do:
##  
## -- Verifies old/new DNS name
##     -- guesses old DNS name based on .env file
##     -- guesses new DNS name based on command line argument
##          -- if no command line argument, uses DNS_NAME variable from /etc/profile.d/load_env
##
## -- Verifies old/new FQDN
##     -- just adds ".cloud.nuxeo.com" on to the old/new DNS name value
##
## -- Find/replace for old DNS name/new DNS name on /etc/profile.d/load_env.sh
##
## -- Exports new DNS_NAME value to update exisiting DNS_NAME env var
##
## -- Deletes old certificate 
##
## -- Edits in-place apache2 conf file
##     -- Find/replace old FQDN/new FQDN
##     -- Deletes SSL stuff (will be replaced later with certbot)
##
## -- Restarts apache
## 
## -- Gets new certificate
## 
## -- Find/replace for old FQDN/new FQDN on /home/ubuntu/nuxeo-presales-docker/.env
##     
## -- Find/replace for old FQDN/new FQDN on /home/ubuntu/.profile
##
## -- Find/replace for old FQDN/new FQDN on each conf file in /home/ubuntu/nuxeo-presales-docker/conf/
## 
## -- Launches new Nuxeo container


## You can verify that the new domain name is working properly by visiting it in your browser
## or you can run `curl https://${DNS_NAME}.cloud.nuxeo.com/nuxeo/runningstatus\?info\=started`


source /etc/profile.d/load_env.sh

GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

DNS_LOG="/var/log/nuxeo_dns.log"

COMPOSE_DIR="/home/ubuntu/nuxeo-presales-docker"
NUXEO_ENV="${COMPOSE_DIR}/.env"

OLD_FQDN=$(grep '^FQDN' ${NUXEO_ENV} | tail -n 1 | cut -d '=' -f2)
FILE_LOG="/var/lib/nuxeo/log/newFQDN_files.log"


## Must be run as root
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi




cat << EOF 

NOTE: FQDN is just DNS_NAME.cloud.nuxeo.com

EOF

# Confirm old DNS name
OLD_DNS_NAME=$(grep '^FQDN' ${NUXEO_ENV} | tail -n 1 | cut -d '=' -f2 | rev | cut -d '.' -f4- | rev)
echo -n "Old DNS name: [${OLD_DNS_NAME}] "
read GET_OLD_DNS_NAME
if [ -n "${GET_OLD_DNS_NAME}" ]
then
    OLD_DNS_NAME="${GET_OLD_DNS_NAME}"
fi

# Confirm new DNS name
NEW_DNS_NAME="${1:-$DNS_NAME}"
echo -n "New DNS name: [${NEW_DNS_NAME}] "
read GET_NEW_DNS_NAME
if [ -n "${GET_NEW_DNS_NAME}" ]
then
    NEW_DNS_NAME="${GET_NEW_DNS_NAME}"
fi

OLD_FQDN="${OLD_DNS_NAME}.cloud.nuxeo.com"
NEW_FQDN="${NEW_DNS_NAME}.cloud.nuxeo.com"
# Confirm FQDN
cat <<EOF

The old FQDN will be replaced by the new FQDN.

Old FQDN: ${OLD_FQDN}
New FQDN: ${NEW_FQDN}

Continue?

EOF

select yn in "Yes" "No"; do
    case $yn in
        Yes ) echo "Continue.."; break;;
        No ) echo "Exited..."; exit;;
    esac
done

## Update /etc/profile.d/load_env.sh with new DNS_NAME value
## Export new DNS_NAME value
sed -i "s/\bDNS_NAME\S*/DNS_NAME=${NEW_DNS_NAME}/" /etc/profile.d/load_env.sh
export DNS_NAME="${NEW_DNS_NAME}"

## Delete old certificate
echo "Deleting old cert..."
certbot delete --non-interactive --cert-name ${OLD_FQDN}
CERT_DELETE=$?
if [[ ${CERT_DELETE} == "0" ]]
then
   echo -e "${GREEN}DONE${RESET}: Deleted cert\n"
else
   echo -e "${RED}FAIL${RESET}: Could not delete cert\n"
fi

## Rewrite Apache conf file
echo -n "Updating Apache conf..."
sed -i "/^SSLCertificate/d
        /options-ssl-apache.conf$/d
        /^Header always set Strict-Transport-Security/d
        /^Header always set Content-Security-Policy/d
        s/${OLD_FQDN}/${NEW_FQDN}/" \
        /etc/apache2/sites-available/nuxeo.conf
APACHE_CONF=$?
if [[ ${APACHE_CONF} == "0" ]]
then
   echo -e "${GREEN}DONE${RESET}: Edited apache conf\n"
else
   echo -e "${RED}FAIL${RESET}: Could not update apache conf\n"
fi

## Restart Apache
echo -n "Restarting Apache...."
service apache2 restart
APACHE_RESTART=$?
if [[ ${APACHE_RESTART} == "0" ]]
then
    echo -e "${GREEN}DONE${RESET}: Apache2 service restarted\n"
else
    echo -e "${RED}FAIL${RESET}: Could not restart apache2 service\n"
fi

## Create new cert
echo -n "Create new cert..."
certbot -q --apache --redirect --hsts --uir --agree-tos -m wwpresalesdemos@hyland.com -d ${NEW_FQDN}
CERT=$?
if [[ ${CERT} == "0" ]]
then
    echo -e "${GREEN}DONE${RESET}: New cert created\n"
else
    echo -e "${RED}FAIL${RESET}: Could not create new cert\n"
fi

## Edit .env file
echo -n "Editing .env file... "
sed -i "s/${OLD_FQDN}/${NEW_FQDN}/" ${NUXEO_ENV}
ENV=$?
if [[ ${ENV} == "0" ]]
then
   echo -e "${GREEN}DONE${RESET}: Updated .env file\n"
else
    echo -e "${RED}FAIL${RESET}: Could not update .env\n"
fi


## Update figlet in .profile
echo -n "Updating figlet in .profile... "
sed -i "s/figlet.*/figlet ${NEW_FQDN}/" /home/ubuntu/.profile
FIG=$?
if [[ ${FIG} == "0" ]]
then
   echo -e "${GREEN}DONE${RESET}: Figlet in .profile updated\n"
else
   echo -e "${RED}FAIL${RESET}: Could not update figlet\n"
fi


## Find files that use old FQDN and replace with new FQDN
echo "The following changes were made to the conf files: "
find "${COMPOSE_DIR}/conf/" -type f -printf '\n%p:\n' -exec sed -i "/${OLD_FQDN}/{
    h
    s//${NEW_FQDN}/g
    H
    x
    s/\n/ >>> /
    w /dev/stdout
    x
    }" {} \;

## Create new nuxeo container
echo -e "\nCreating new nuxeo container..."
if [[ ${APACHE_RESTART} == "0" && ${CERT} == "0" ]]; then
#    make -e -f ${COMPOSE_DIR}/Makefile SERVICE=nuxeo new
    docker-compose --project-directory ${COMPOSE_DIR} --file ${COMPOSE_DIR}/docker-compose.yml rm --force --stop nuxeo
    docker-compose --project-directory ${COMPOSE_DIR} --file ${COMPOSE_DIR}/docker-compose.yml up --detach nuxeo
    echo -e "${GREEN}DONE${RESET}: Created new nuxeo container\n"
else
    echo -e "${RED}FAIL:${RESET}Did not create new nuxeo container\n"
fi