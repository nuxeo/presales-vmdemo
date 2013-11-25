#!/bin/bash

# This script file will update the data of the demo and then reset it. The demo path should be updated automatically when the demo is created.

cd /etc/nuxeo_snapshot_demo/scripts
./01-updateFullDemoFromFromWeb.sh
./000-resetLocal.sh

