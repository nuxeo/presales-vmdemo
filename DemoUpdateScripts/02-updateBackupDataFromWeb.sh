#!/bin/bash
# This script gets demo data (sql dump and binaries) from Nuxeo servers and extract them so that they can then be used by the resetLocal scripts. Data are available in english and french.

if test ! ${VARIABLES_INITIALIZED}
then
	echo "Initializing data"	
	source ./99-initScriptVariables.sh || exit 1
fi

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1

wget -N "${NUXEO_DEMO_SITE}${NUXEO_DEMO_DATAS}.tar.gz"|| exit 1

if test -d ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_DATAS}
then
	echo "Older data found, resetting it"
	rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_DATAS}
fi

echo "Extracting data"
tar xzf ${NUXEO_DEMO_DATAS}.tar.gz || exit 1
wait
echo "Data extracted"

