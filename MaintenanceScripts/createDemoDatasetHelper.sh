#!/bin/bash

# This script has been designed to help creating a new standard demo dataset.




echo '========================================'
echo 'Welcome in Nuxeo demo dataset helper!'
echo 'The script requires to get a script from Nuxeo Servers, so you should be connected to the web'
echo 'If you have never reset your demo, preliminary manuel steps should be done on the database, take a look at https://github.com/nuxeo/presales-vmdemo for more informations'

read -p 'Please enter a name for your demo snapshot (a folder will be created with that name).' NUXEO_DEMO_DIR
#The name of the demo folder (will be created if does not exist)
NUXEO_DEMO_DIR=${NUXEO_DEMO_DIR:-nuxeo_demo_dataset}


#The Folder where to put the demo folder (by default the folder where the script is run)
NUXEO_DEMO_PARENT_DIR=${NUXEO_DEMO_PARENT_DIR:-$PWD}



echo "Getting necessary scripts from Github"


if test ! -d ${NUXEO_DEMO_PARENT_DIR}
then
	echo "The folder to store the demo materials does not seems to exit. Please edit the file to point to an existing folder."
	exit 1
fi

if test ! -d ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
then 
	echo "No previous dataset with the same name: "
	echo ${NUXEO_DEMO_DIR}
	echo "Trying to create it"
else
	echo "Older Demo dataset found: "
	echo ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
	echo "Do you wish to erase the older dataset (choose the number of the option you prefer)?"
	select yn in "Yes" "No"; do
    		case $yn in
        		Yes ) break;;
        		No ) exit;;
    		esac
	done
	echo "removing old dataset"
	rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}
fi

echo 'Creating snapshot dir'
mkdir ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1

echo 'Creating script dir to store reset script'
mkdir ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/scripts

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/scripts || exit 1

wget "https://raw.github.com/nuxeo/presales-vmdemo/master/DemoUpdateScripts/99-initScriptVariables.sh" --no-check-certificate || exit 1

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

if test ! -e ${NUXEO_CONF}
then
	echo "Nuxeo Conf cannot be found at expected location, please edit the script 99-initScriptVariables to locate nuxeo.conf file"
	echo ${NUXEO_CONF}
	exit
fi

DB_NAME=`grep "^nuxeo.db.name=" $NUXEO_CONF | cut -d= -f2`
DB_PORT=`grep "^nuxeo.db.port=" $NUXEO_CONF | cut -d= -f2`
DATA_DIR=`grep "^nuxeo.data.dir=" $NUXEO_CONF | cut -d= -f2`

echo 'Dumping DB'
pg_dump -p ${DB_PORT} -f demo.dump ${DB_NAME}
wait
echo 'dump DB OK, do not forget to clean the warnings in the dump file'
echo 'Storing binaries'
mkdir binaries
cd binaries
cp -R ${DATA_DIR}/binaries/* ./ || exit 1

cd ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR} || exit 1
echo 'Zipping the data'
echo ${NUXEO_DEMO_PARENT_DIR}'/'${NUXEO_DEMO_DIR}'/'${NUXEO_DEMO_DATAS}
tar cvzf ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/datas.tar.gz ${NUXEO_DEMO_DATAS}
rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_DATAS}

echo 'Data are saved'

echo "Do you have specific configuration templates in your demo? (specific items you added to nuxeo.templates in nuxeo.conf)"
echo "If you do not really no, you can say no, take a look at your nuxeo.conf and copy the specific templates path if any and relaunch the script"
select yn in "Yes" "No"; do
    	case $yn in
        	Yes ) break;;
        	No ) exit;;
    	esac
done

read -p 'Please give the full path of the templates (something looking like: /etc/nuxeo/myTemplates).' ORIGINAL_TEMPLATES
echo ${ORIGINAL_TEMPLATES}

mkdir ${NUXEO_DEMO_TEMPLATES}
mkdir ${NUXEO_DEMO_TEMPLATES}/custom

cp -R ${ORIGINAL_TEMPLATES}/*  ${NUXEO_DEMO_TEMPLATES}/custom/

tar cvfz ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/templates.tar.gz ${NUXEO_DEMO_TEMPLATES}

rm -r ${NUXEO_DEMO_PARENT_DIR}/${NUXEO_DEMO_DIR}/${NUXEO_DEMO_TEMPLATES}
rm -r scripts
echo "Templates saved"
