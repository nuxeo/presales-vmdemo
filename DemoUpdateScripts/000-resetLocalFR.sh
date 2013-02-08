#!/bin/bash
# This script reset the server with local demo data, no web connection is required.

LANGUAGE=fr
if test ! ${VARIABLES_INITIALIZED}
then
	echo "Initializing variables"	
	source ./99-initScriptVariables.sh || exit 1
fi


ResetDumpDemoDB=${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/datas/${LANGUAGE}/demo.dump

echo 'reseting nuxeo.conf'
cp ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/nuxeo.conf.backup /etc/nuxeo/nuxeo.conf || exit 1

DATA_DIR=`grep "^nuxeo.data.dir=" $NUXEO_CONF | cut -d= -f2`
DB_NAME=`grep "^nuxeo.db.name=" $NUXEO_CONF | cut -d= -f2`
DB_PORT=`grep "^nuxeo.db.port=" $NUXEO_CONF | cut -d= -f2`

${NUXEO_SERVER_DIR}/bin/nuxeoctl stop
wait
killall soffice.bin> /dev/null #just to make sure OOo is shut down.
echo 'Nuxeo DM Demo has been stopped.'
echo 'Database will be dropped'
dropdb -p ${DB_PORT} ${DB_NAME} || exit 1
wait
echo 'Database dropped'
createdb -p ${DB_PORT} -E UTF8 ${DB_NAME} || exit 1
psql -p ${DB_PORT} -d ${DB_NAME} -c "ALTER DATABASE nuxeo OWNER TO nuxeo;" || exit 1
wait
echo 'Empty database recreated - will now be filled'
psql -p ${DB_PORT} -d ${DB_NAME} -f $ResetDumpDemoDB >/dev/null
wait
echo 'Database was recreated with complete set of demo data'
rm -R ${DATA_DIR}/*
rm -R ${NUXEO_SERVER_DIR}/*
wait
echo 'Server and Data deleted'
echo 'Server Creation'
cp -R ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/distribution/server/* ${NUXEO_SERVER_DIR}/ || exit 1
cp -R ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/distribution/data/* ${DATA_DIR}/ || exit 1
wait
echo 'Server recreated, copying demo data' 
cp -R ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/datas/${LANGUAGE}/binaries ${DATA_DIR} || exit 1
wait
echo 'Data reset' 

echo 'Installation of addons'
${NUXEO_SERVER_DIR}/bin/nuxeoctl mp-install --accept=true --nodeps ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_PACKAGES}/*
wait

wait
${NUXEO_SERVER_DIR}/bin/nuxeoctl start

