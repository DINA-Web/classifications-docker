#!/bin/bash
cat header.xml > a.xml
tail -n +6 boho.xml >> a.xml
mv a.xml boho.xml
python animalia_xml2csv.py

