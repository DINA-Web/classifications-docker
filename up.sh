#!/bin/bash
echo "Pulling latest sources"
./pre_up.sh

echo "Starting dw-collections"
docker-compose up -d

echo "Loading data and starting"
./post_up.sh

echo "Done"
