#!/bin/bash

echo "Running upload for specific xml files"

echo "Note that setting up client OAuth details is required, use http://localhost:7000/admin"
echo "Login with the admin user, set up a new client (can use bogus url and redirect uri)"
echo "Take note of client id and secret
echo "TODO: automate this step"

echo "It is recommended to turn off realtime indexing in settings"
echo "HAYSTACK_SIGNAL_PROCESSOR for quicker data upload"
echo "and to rebuild index after that."
echo "TODO: automate this step"

# Note: ids could be read from all numerical xml files in the dir"
# Here those ids are listed manually
#ids="6001047 5000001 5000039 5000045 5000052 5000055 5000060 5000082 3000188 2001251"
ids="3000188"

for id in $ids
do
  # this modifies the xml dl; sets a valid xml header
  cat header.xml > temp.xml
  tail -n +6 $id.xml >> temp.xml
  mv temp.xml ul.$id.xml
  python xml_batch_upload.py ul.$id.xml
# When re-uploading, specify the root node id like below
# doesnt work? returns 400 bad request
# python xml_batch_upload.py -t $id ul.$id.xml
done

