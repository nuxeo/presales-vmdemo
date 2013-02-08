#!/bin/bash
# This script run all update from Nuxeo Server to get data, templates, packages and a fresh distribution. A reset should be run after this script as the server is modified during the updates.

echo "Initializing data"	
source ./99-initScriptVariables.sh || exit 1

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1

./scripts/02-updateBackupDataFromWeb.sh || exit 1
./scripts/03-updateBackupTemplatesFromWeb.sh || exit 1
./scripts/04-updateBackupPackagesFromWeb.sh || exit 1
./scripts/05-updateAndPrepareDistribFromWeb.sh || exit 1
