#/bin/sh
studioProject=your-studio-id
containerName=any-name-you-want

# Delete local copy of Studio project.
rm -rf ./store/$studioProject-0.0.0-SNAPSHOT

# Start container
# Note that the container is deleted when finished with the --rm switch to save space
# Note that several container folders are mapped to the local file system with -v for convenience
# Add your Nuxeo Packages to NUXEO_PACKAGES
# Add your custom plugins to /packages on your local file system
docker run --name $containerName -it -p 8080:8080 -p 8787:8787 --rm \
-e TZ=US/Pacific \
-e NUXEO_CLID="your CLID" \
-e NUXEO_INSTALL_HOTFIX="true" \
-e NUXEO_DEV_MODE="true" \
-e NUXEO_PACKAGES="nuxeo-jsf-ui $studioProject nuxeo-dam nuxeo-spreadsheet nuxeo-template-rendering nuxeo-drive /opt/nuxeo/plugins/*.zip" \
-v `pwd`/store:/opt/nuxeo/server/packages/store/ \
-v `pwd`/h2:/var/lib/nuxeo/data/h2/ \
-v `pwd`/binaries:/var/lib/nuxeo/data/binaries/ \
-v `pwd`/elasticsearch:/var/lib/nuxeo/data/elasticsearch/ \
-v `pwd`/packages:/opt/nuxeo/plugins/ \
-v `pwd`/nuxeo.war:/opt/nuxeo/server/nxserver/nuxeo.war/ \
-v `pwd`/logs:/var/log/nuxeo/ \
-v `pwd`/plugins:/opt/nuxeo/server/nxserver/plugins/ \
-e NUXEO_CUSTOM_PARAM="JAVA_OPTS=$JAVA_OPTS -Xdebug -Xrunjdwp:transport=dt_socket,address=8787,server=y,suspend=n \n \
mail.transport.host=smtp.gmail.com \n \
mail.transport.port=587 \n \
mail.transport.auth=true \n \
mail.transport.usetls=true \n \
mail.transport.username=YOUREMAIL@gmail.com \n \
mail.transport.password=PASSWORD \n \
mail.transport.userYOUREMAIL@gmail.com \n \
mail.from=YOUREMAIL@gmail.com" \
nuxeo:latest
