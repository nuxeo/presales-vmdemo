#!/bin/bash
# This script gets demo templates from Nuxeo server and extracts them so they can be used by nuxeo.conf.

if test ! ${VARIABLES_INITIALIZED}
then
	echo "Initializing variables"	
	source ./99-initScriptVariables.sh || exit 1
fi

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1


if test -d ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_PACKAGES}
then
	echo "Older packages found, resetting them"
	rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_PACKAGES} || exit 1
else
	echo "No previous packages found, creating the structure."
fi
mkdir ${NUXEO_DEMO_PACKAGES}  || exit 1
cd ${NUXEO_DEMO_PACKAGES} || exit 1
echo "getting packages"
wget -r --no-parent -nd -A '.zip' "${NUXEO_DEMO_SITE}${NUXEO_DEMO_PACKAGES}"|| exit 1
echo "Packages updated"

