#!/bin/bash

# echo "Installing Python suds library for accessing SOAP web service data"
# sudo apt-get install python-pip
# sudo pip install suds

echo "Running dyntaxa import for specific ids"
ids="6001047 5000012 5000022 5000029 5000027 5000026 5000032 5000034 5000005 5000006 5000025 5000031 5000019 5000024 5000010 5000011 5000033 5000015 5000016 5000098 5000023 5000021 5000017 5000018 5000004 5000028 5000099 5000007 5000002 5000014 5000003 5000008 5000020 5000013 6000992 5000039 5000045 5000052 5000055 5000060 5000082 3000188 2001251"
#ids="3000188"

for id in $ids
do
  python dyntaxa.py --ids "$id"
done

echo "Please review new .xml file(s). Done"

# 6001047   Algae
# 5000001   Animalia
# 5000039   Fungi
# 5000045   Plantae
# 5000052   Bacteria
# 5000055   Chromis ta
# 5000060   Protozoa
# 5000082   Archaea
# 3000188   Lepidoptera
# 2001251   Papilionidae
