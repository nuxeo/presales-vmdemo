presales-vmdemo
===============
This repository contains the scripts used by Nuxeo Presales team to generate and maintain a demo server with many plugins and demo data.

You can use the following instruction to set up your own demo server on ubuntu.


# Instruction to deploy or update a demo server

Here are the instruction to deploy the nuxeo demo set of data on a fresh nuxeo install on Ubuntu+postgres.

### Prepare your server


If not done, install Nuxeo with PostgreSQL on ubuntu.
See here for installation instructions on Ubuntu.
http://doc.nuxeo.com/x/3oON

If you prefer, you can also use one of the Nuxeo VM
http://www.nuxeo.com/en/downloads (run the installation wizard before going further)

Once Nuxeo is installed with autoconfiguration of the postgres database, it has created a nuxeo role in postgres that need to be modified for the deployment script to run.

- connect to a terminal and type : 

$ sudo su - postgres;

$ psql -p 5433;  

$ ALTER ROLE nuxeo WITH CREATEDB;

$ \q

$ exit;

`Note "5433" is your nuxeo database port, if this is not 5433, you can find it in the nuxeo.conf file : nuxeo.db.port (/etc/nuxeo). The default port on Nuxeo downloaded VM is 5432`

### Fetch demo datas and reset the server

- Then we will fetch the deployment script and launch it as a nuxeo user (to make sure we have the write permissions) :

$ cd /etc/nuxeo;

$ sudo su - nuxeo;

$ wget "https://raw.github.com/nuxeo/presales-vmdemo/master/00-DownloadAndSetUpFullNuxeoDemo.sh";

$ chmod +x 00-DownloadAndSetUpFullNuxeoDemo.sh;

$ . 00-DownloadAndSetUpFullNuxeoDemo.sh;

- it will download all the data, and restart the server 

`unzip package must be already installed on your server so that the script can run, and it is not installed by default on nuxeo VMs, to install it:
sudo apt-get install unzip`

You can connect to your server

Have fun with the demo!!!

### Update logic and Getting hotfixes for you demo server.
#### Update and reset logic

The scripts are designed so that you can reset your server even when offline (of course the server should be connected for the first update).
The logic is the following, when 00-DownloadAndSetUpFullNuxeoDemo is launched. It creates the demo structure in the current folder and download a bunch of updates scripts (in the demo folder in scripts) and the reset local scripts and then launch all of them one after other.

The update scripts fetch from Nuxeo server all the information:

- data (binaries+SQL Dump) in english and french in the folder data (02-updateBackupDataFromWeb)

- Templates in the folder templates (03-updateBackupTemplatesFromWeb)

- Market place packages in the folder packages (04-updateBackupPackagesFromWeb)

- A Fresh distribution (05-updateAndPrepareDistribFromWeb)

The download of the distribution is little bit more complex so that it can be hotfixed at the update and then reuse (even offline) at the reset local. Basically, it downloads the distrib, deploy it, install DM, DAM, SC, try to hotfix the distrib and save everything to reuse it at reset.

`All update scripts mentionned can be run independently if needed`


#### Hotfix the demo server

A bunch of marketplace packages is provided but no hotfixes, to hotfix the distrib you need to provide an instance.clid that should be put at the same level than 00-DownloadAndSetUpFullNuxeoDemo.
When the script 05-updateAndPrepareDistribFromWeb is run, it will fetch the distrib, init it, hotfix and save it in order to use when 000-resetlocal is run.
The instance clid will also be copied into the server.

`05-updateAndPrepareDistribFromWeb will modify the installed server to create the demo one, so a reset should be run after this script`

As scripts can be run separately, it can be a good idea to run 05-updateAndPrepareDistribFromWeb from time to time with a valid instance.clid to keep a demo server up to date.



## The demo set


You can connect to it with user (pwd) : 

- Administrator/Administrator - Administrator of the system, the only one to see the admin center
- Bill/Bill - Is manager of the IT department directory, can be used as the reference user.
- John/John - This user only access to sections, good way to see the effect of permissions.
- Steve/Steve - A standard user.

Many plugins and modules are installed including: 

- DAM
- Social Collab
- Template rendering
- Nuxeo Diff

The full list can be found in the admin center, local packages.


## Reseting the server with local demo data in english or french
 
If you want to reset your demo without downloading and redeploying everything again, you can go to the folder nuxeo_demo/scripts (where you launched 000-DownloadAndSetUpFullNuxeoDemo.sh) and launch 000-resetLocalEn.sh (It's important that you are connected as nuxeo)

Note that there are also data in French if you prefer, in that case just run 000-resetLocalFR.sh

## Customizing your demo
In the demo folder (by default in nuxeo_demo where you initally run 00-DownloadAndSetUpFullNuxeoDemo.sh), you will see several folders. Each of them contains a part of the demo that you can customise if you want to

- packages : these are marketplace packages (https://connect.nuxeo.com/nuxeo/site/marketplace/product/all). You can add or remove existing packages. All packages in that folder will be installed at the next 000-resetLocal (if a package is removed from the folder, it will be remove also)
- templates : a place to put any custom jars or XML.
- data : if you have your own binaries + SQL Dump, you can put them here
- distribution : this one is generated automatically, it is recommanded that you do not modify it.


