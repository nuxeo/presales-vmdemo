#!/bin/bash

if test ! ${VARIABLES_INITIALIZED}
then
	echo "Initializing data"	
	source ./99-initScriptVariables.sh || exit 1
fi

LOG_DIR=`grep "^nuxeo.log.dir=" $NUXEO_CONF | cut -d= -f2`

tail -f ${LOG_DIR}/server.log

