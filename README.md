presales-vmdemo
===============

Presales tooling for demos

`Work in progress, do not use for now`


# Instruction to deploy or update a demo server

Here are the instruction to deploy the nuxeo demo set of data on a fresh nuxeo install on Ubuntu+postgres.

## Prepare your server


If not done, install Nuxeo with DM, DAM and Social Collab.
See here for installation instructions on Ubuntu.
http://doc.nuxeo.com/x/3oON

Once Nuxeo is installed with autoconfiguration of the postgres database, it has created a nuxeo role in postgres that need to be modified for the deployment script to run.

- connect to a terminal and type : 
sudo su postgres;
psql -p 5433;  
ALTER ROLE nuxeo WITH CREATEDB;
\q
exit;

`Note "5433" is your nuxeo database port, if this is not 5433, you can find it in the nuxeo.conf file : nuxeo.db.port (/etc/nuxeo)`


- Then we will fetch the deployment script and launch it as a nuxeo user (to make sure we have the write permissions) :
cd /etc/nuxeo;
sudo su nuxeo;
TO BE UPDATED (wget http://clients.nuxeo.com/NUXEODEMO/VM/deploy_nuxeo_demo_ubuntu.sh;
. deploy_nuxeo_demo_ubuntu.sh;)

- it will download all the data, and restart the server 

You can connect to our server

Have fun with the demo!!!

You can connect to it with user (pwd) : 
Administrator/Administrator - Administrator of the system, the only one to see the admin center
Bill/Bill - Is manager of the IT directory, can be used as the reference user.
John/John - This user only access to sections, good way to see the effect of permissions.
Steve/Steve - A standard user.



Note : 
If you want to reset your demo without downloading and redeploying everything again, you can go to the folder nuxeo_demo/scripts (where you launched deploy_nuxeo_demo_ubuntu_en.sh) and launch 000-reset_en.sh (It's important that you are connected as nuxeo)