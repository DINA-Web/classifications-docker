#!/bin/bash
echo "Installing db schema and running tests"
docker exec dwclassifications_web_1 /code/init_once.sh
sudo chown -R $USER:$USER ./plutof-taxonomy-module
