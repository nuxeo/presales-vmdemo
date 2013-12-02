#!/bin/bash
# This script gets demo templates from Nuxeo server and extracts them so they can be used by nuxeo.conf.

if test ! ${VARIABLES_INITIALIZED}
then
	echo "Initializing variables"	
	source ./99-initScriptVariables.sh || exit 1
fi

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1


# check if templates file exists on demo site server
wget -S --spider  "${NUXEO_DEMO_SITE}${NUXEO_DEMO_TEMPLATES}.tar.gz"

if [ $? -eq 0 ]
then

  wget -N "${NUXEO_DEMO_SITE}${NUXEO_DEMO_TEMPLATES}.tar.gz"|| exit 1
  
  if test -d ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_TEMPLATES}
  then
  	echo "Older templates found, resetting it"
  	rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_TEMPLATES}
  fi
  
  echo "Extracting templates"
  tar xzf ${NUXEO_DEMO_TEMPLATES}.tar.gz || exit 1
  wait
  echo "Templates extracted"
  
fi 
  
