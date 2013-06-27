#!/bin/bash

echo ${PWD}
#The Folder where to put the demo folder (by default the folder where the script is run)
NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-$PWD}
#The name of the demo folder (will be created if does not exist)
NUXEO_DEMO_DIR=${NUXEO_DEMO_DIR:-nuxeo_demo}


#wget "https://clients.nuxeo.com/NUXEODEMO/VM/nuxeo_demo.tar.gz"
#echo "unzipping demo data"
#tar xvzf nuxeo_demo.tar.gz

if test ! -d ${NUXEO_DEMO_PARENT_DIR}
then
	echo "The folder to store the demo materials does not seems to exit. Please edit the file to point to an existing folder."
	exit 1
fi

if test ! -d ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
then 
	echo "Demo folder not found in: "
	echo ${NUXEO_DEMO_PARENT_DIR}
	echo "Trying to create it"
else
	echo "Demo folder found in: "
	echo ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
	echo "Updating data"
	rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
fi

mkdir ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1
mkdir ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/scripts

#Getting a reset script for easy reset without going into the script folder
cd ${NUXEO_DEMO_PARENT_DIR}
echo 'Getting reset script from github'
wget -O reset_${NUXEO_DEMO_DIR}.sh "https://raw.github.com/nuxeo/presales-vmdemo/master/MaintenanceScripts/resetGeneric.sh" --no-check-certificate || exit 1
chmod +x reset_${NUXEO_DEMO_DIR}.sh || exit 1
sed -i -e s@'cd /etc/nuxeo_snapshot_demo/scripts'@'cd '${NUXEO_DEMO_PARENT_DIR}'/'${NUXEO_DEMO_DIR}'/scripts'@ reset_${NUXEO_DEMO_DIR}.sh || exit 1
sed -i -e s@'./000-resetLocal.sh'@'./000-resetLocalEn.sh'@ reset_${NUXEO_DEMO_DIR}.sh || exit 1

#Getting an update and reset script for easy reset without going into the script folder

echo 'Getting update and reset script from github'
wget -O update_and_reset_${NUXEO_DEMO_DIR}.sh "https://raw.github.com/nuxeo/presales-vmdemo/master/MaintenanceScripts/resetAndUpdateGeneric.sh" --no-check-certificate || exit 1
chmod +x update_and_reset_${NUXEO_DEMO_DIR}.sh || exit 1
sed -i -e s@'cd /etc/nuxeo_snapshot_demo/scripts'@'cd '${NUXEO_DEMO_PARENT_DIR}'/'${NUXEO_DEMO_DIR}'/scripts'@ update_and_reset_${NUXEO_DEMO_DIR}.sh || exit 1
sed -i -e s@'./000-resetLocal.sh'@'./000-resetLocalEn.sh'@ reset_${NUXEO_DEMO_DIR}.sh || exit 1

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/scripts || exit 1

echo "Getting demo scripts"

wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/01-updateFullDemoFromFromWeb.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/02-updateBackupDataFromWeb.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/03-updateBackupTemplatesFromWeb.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/04-updateBackupPackagesFromWeb.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/05-updateAndPrepareDistribFromWeb.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/99-initScriptVariables.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/000-resetLocalEn.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/000-resetLocalFR.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/000-restart.sh" --no-check-certificate || exit 1
wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/000-showLog.sh" --no-check-certificate || exit 1

chmod +x ./* || exit 1

echo "All scripts downloaded"
echo "Updating the init variable scripts with the correct variables"

sed -i -e s@'export NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-/etc/nuxeo}'@'export NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-'${NUXEO_DEMO_PARENT_DIR}'}'@ 99-initScriptVariables.sh || exit 1

echo "Fetching demo data from Nuxeo Servers"
./01-updateFullDemoFromFromWeb.sh || exit 1
wait
echo "Resetting the server with the demo data. The server will stop if you close the window after (juste restart the server in that case)"
./000-resetLocalEn.sh






