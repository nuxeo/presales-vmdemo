#!/bin/bash
# This script initialize variables all other scripts about the demo. It's role is to centralize all information that could change.

#The Folder where to put the demo folder
export NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-/etc/nuxeo}
#The name of the demo folder (will be created if does not exist)
export NUXEO_DEMO_DIR=${NUXEO_DEMO_DIR:-nuxeo_FT_demo}

#Variables used by the scripts (should not be edited by the user)
#Nuxeo demo data backup site
export NUXEO_DEMO_SITE=${NUXEO_DEMO_SITE:-https://clients.nuxeo.com/NUXEODEMO/VM/nuxeo_FT_demo/}


#Nuxeo demos scripts, data, templates
#export NUXEO_DEMO_SCRIPTS=${NUXEO_DEMO_SCRIPTS:-scripts}
export NUXEO_DEMO_DATAS=${NUXEO_DEMO_DATAS:-datas}
export NUXEO_DEMO_TEMPLATES=${NUXEO_DEMO_TEMPLATES:-templates}
export NUXEO_DEMO_PACKAGES=${NUXEO_DEMO_PACKAGES:-packages}

# Variables used by subscripts : 
#The distribution download link

#Calculated dynamically in the 05-UpdateAndPrepareDistrib
#export NUXEO_DISTRIB=${NUXEO_DISTRIB:-nuxeo-cap-5.6-tomcat}

export NUXEO_DISTRIB_DOWNLOAD_LINK=${NUXEO_DISTRIB_DOWNLOAD_LINK:-http://community.nuxeo.com/static/snapshot/}

export NUXEO_CONF=${NUXEO_CONF:-/etc/nuxeo/nuxeo.conf}
export NUXEO_SERVER_DIR=${NUXEO_SERVER_DIR:-/var/lib/nuxeo/server}


export VARIABLES_INITIALIZED=true

