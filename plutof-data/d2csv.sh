#!/bin/bash

ids="3000188"

for id in $ids
do
  # this modifies the xml dl; sets a valid xml header
  cat header.xml > temp.xml
  tail -n +6 $id.xml >> temp.xml
  mv temp.xml ul.$id.xml
  mv ul.$id.xml $id.xml
  python d2csv.py --id $id
done

