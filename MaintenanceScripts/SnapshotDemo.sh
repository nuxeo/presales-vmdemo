#!/bin/bash

# This script file intends at creating a snapshot of a Nuxeo demo server. While other demo data sets are designed to be as flexible as possible to add or remove package, change server version, this snapshot will copy the server and the data as there are. To update a snapshot demo created with this script, you should reset your demo, update it and recreate a new snapshot.



#Variables

echo '========================================'
echo 'Welcome to Nuxeo demo snapshot creator!'
echo 'The script needs to get a script from Nuxeo Servers, so you should be connected to the web'
echo 'If you have never reset your demo, preliminary manual steps should be done on the database, take a look at https://github.com/nuxeo/presales-vmdemo for more information'
read -p 'Please enter a name for your demo snapshot (a folder will be created with that name): ' NUXEO_DEMO_DIR

#The Folder where to put the demo folder (by default the folder where the script is run)
NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-$PWD}
#The name of the demo folder (will be created if does not exist)
NUXEO_DEMO_DIR=${NUXEO_DEMO_DIR:-nuxeo_snapshot_demo}


if test ! -d ${NUXEO_DEMO_PARENT_DIR}
then
	echo "The folder to store the demo materials does not seems to exist. Please edit the file to point to an existing folder."
	exit 1
fi

if test ! -d ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
then 
	echo "No previous snapshot with the name: "
	echo ${NUXEO_DEMO_DIR}
	echo "Trying to create it"
else
	echo "Older Demo snapshot found: "
	echo ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
	echo "Do you wish to erase the older snapshot (choose the number of the option you prefer)?"
	select yn in "Yes" "No"; do
    		case $yn in
        		Yes ) break;;
        		No ) exit;;
    		esac
	done
	echo "removing old snapshot"
	rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
fi

echo 'Creating snapshot dir'
mkdir ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1

echo 'Creating script dir to store reset script'
mkdir ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/scripts

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/scripts || exit 1

echo "Getting reset scripts from Github"

wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/99-initScriptVariables.sh" --no-check-certificate || exit 1
wget -O 000-resetLocal.sh "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/000-resetLocal.sh" --no-check-certificate || exit 1

chmod +x ./* || exit 1

sed -i -e s@'export NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-/etc/nuxeo}'@'export NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-'${NUXEO_DEMO_PARENT_DIR}'}'@ 99-initScriptVariables.sh || exit 1

sed -i -e s@'export NUXEO_DEMO_DIR=${NUXEO_DEMO_DIR:-nuxeo_demo}'@'export NUXEO_DEMO_DIR=${NUXEO_DEMO_DIR:-'${NUXEO_DEMO_DIR}'}'@ 99-initScriptVariables.sh || exit 1

if test ! ${VARIABLES_INITIALIZED}
then
	echo "Initializing data"	
	source ./99-initScriptVariables.sh || exit 1
fi


mkdir ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_DATAS}
cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_DATAS}

DB_NAME=`grep "^nuxeo.db.name=" $NUXEO_CONF | cut -d= -f2`
DB_PORT=`grep "^nuxeo.db.port=" $NUXEO_CONF | cut -d= -f2`

echo 'Dumping DB'
pg_dump -p ${DB_PORT} -f demo.dump ${DB_NAME}
wait
echo 'dump DB OK, do not forget to clean the warnings in the dump file'
echo 'Storing binaries'
mkdir binaries
cd binaries
cp -R /var/lib/nuxeo/data/binaries/* ./ || exit 1

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1

if test ! -e ${NUXEO_CONF}
then
	echo "Nuxeo Conf cannot be found at expected location, please edit the script 99-initScriptVariables to locate nuxeo.conf file"
	echo ${NUXEO_CONF}
	exit
fi

if test ! -d ${NUXEO_SERVER_DIR}
then
	echo "No nuxeo server found at expected location,please edit the script 99-initScriptVariables to locate server dir"
	echo ${NUXEO_SERVER_DIR}
	exit
fi

mkdir distribution || exit 1

echo "Backup of original nuxeo conf"
cp ${NUXEO_CONF} nuxeo.conf.backup || exit 1

echo "Stopping possibly running nuxeo server"
${NUXEO_SERVER_DIR}/bin/nuxeoctl stop

NUXEO_DATA_DIR=`grep "^nuxeo.data.dir=" $NUXEO_CONF | cut -d= -f2`

mkdir distribution/server || exit 1
mkdir distribution/data || exit 1

cp -r $NUXEO_SERVER_DIR/* distribution/server/ || exit 1
cp -r ${NUXEO_DATA_DIR}/* distribution/data/ || exit 1
rm -r distribution/data/binaries/

echo ' Your snapshot is ready, reset script as also been created where you launched the snapshot script, use it whenever you want a clean demo state.'

cd ${NUXEO_DEMO_PARENT_DIR}

echo 'Getting reset script from github'
wget -O reset_${NUXEO_DEMO_DIR}.sh "https://raw.github.com/nuxeo/presales-vmdemo/master/MaintenanceScripts/resetGeneric.sh" --no-check-certificate || exit 1


chmod +x reset_${NUXEO_DEMO_DIR}.sh || exit 1

sed -i -e s@'cd /etc/nuxeo_snapshot_demo/scripts'@'cd '${NUXEO_DEMO_PARENT_DIR}'/'${NUXEO_DEMO_DIR}'/scripts'@ reset_${NUXEO_DEMO_DIR}.sh || exit 1



echo 'Note : As they have already been deployed, Configuration templates are not backup and so you should remove them from the stored nuxeo.conf or you may have warnings at startup.'
# NOTE template are not kept yet at it would involve parsing the nuxeo.conf. 



