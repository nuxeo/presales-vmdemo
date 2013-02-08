#!/bin/bash

#Variables
LANGUAGE=en
#LANGUAGE=fr

echo 'edit the file to adapt to langage'

#Copy blob store and database only
pg_dump -p 5433 -f /etc/nuxeo/nuxeo_demo/datas/${LANGUAGE}/demo.dump nuxeo
wait
echo 'dump DB OK, do not forget to clean the warnings in the dump file'
rm -R  /etc/nuxeo/nuxeo_demo/datas/${LANGUAGE}/binaries/*
wait
echo 'rm old data OK'
cp -R /var/lib/nuxeo/data/binaries/* /etc/nuxeo/nuxeo_demo/datas/${LANGUAGE}/binaries/
wait
echo 'done'
