# -*- coding: utf-8 -*-
"""
@author: markus
"""

import sys, getopt
import os.path
from suds.client import Client
from suds import WebFault
from ConfigParser import SafeConfigParser

CFG = "dyntaxa-credentials.cfg"
IDS = "5000001"  # animalia

manual = "dyntaxa.py --cfg <default:" + CFG + "> --ids '<default:" + IDS + ">'"

try:
  opts, args = getopt.getopt(sys.argv[1:], "hci", ["cfg=", "ids="])
except getopt.GetoptError:
  print manual
  sys.exit(2)

for opt, arg in opts:
  if opt in ("-h", "--help", "-?", "--?"):
    print manual
    sys.exit()
  elif opt in ("-c", "--cfg"):
     CFG = arg
  elif opt in ("-i", "--ids"):
     IDS = arg
     
if not os.path.isfile(CFG):
  print "Config file does not exist. Exiting."
  raise SystemExit(0)
print 'Using cfg: ', CFG

id_list = IDS.split(' ')
for i in id_list:
  if not i.isdigit():
    print "The ids need to be numerical taxon ids. Exiting"
    raise SystemExit(0)


SVC_URL = 'https://taxon.artdatabankensoa.se/TaxonService.svc?wsdl'
client = Client(SVC_URL, timeout=600)
#print(client)
#exit(0)

online = client.service.Ping()
if not online:
  print 'Service not online. Exiting.'
  raise SystemExit(0)
print "Service " + SVC_URL + " is online, logging in..."

#XML_OUT = "_".join(id_list) + ".xml"
XML_OUT = "boho.xml"
if os.path.isfile(XML_OUT):
  print "Results file " + XML_OUT + " already exists, already downloaded? Aborting .."
  exit(0)


# Read user account credentials from config file
config = SafeConfigParser()
config.read(CFG)
SVC_USER = config.get('Dyntaxa', 'user')
SVC_PASS = config.get('Dyntaxa', 'pass')

login = client.service.Login(SVC_USER, SVC_PASS, SVC_USER, False)

wci = client.factory.create('ns1:WebClientInformation')
wci['Locale'] = login.Locale
wci['Token'] = login.Token

wttsc = client.factory.create('ns1:WebTaxonTreeSearchCriteria')

#print wttsc
#exit(0)
#op = client.factory.create('ns0:LogicalOperator')
#wttsc['FieldLogicalOperator'] = op.And

ttsc = client.factory.create('ns0:TaxonTreeSearchScope')
wttsc['Scope'] = ttsc.NearestChildTaxa

wtc = client.factory.create('ns1:WebTaxonCategory')
tcids = client.factory.create('ns3:ArrayOfint')
tcids.int.append(2)  # phylum
wtc['Id'] = tcids 
wttsc['TaxonCategoryIds'] = tcids

tids = client.factory.create('ns3:ArrayOfint')
for id in id_list:
  tids.int.append(id)
wttsc['TaxonIds'] = tids

print "Retrieving ids: " + IDS
try:
#  result = client.service.GetTaxonCategoriesByTaxonId(wci, ids[0])
  result = client.service.GetTaxonTreesBySearchCriteria(wci, wttsc)
except WebFault, e:
  print e
  raise SystemExit(0)

print "Writing results to " + XML_OUT
fo = open(XML_OUT, "wb")
fo.write(bytes(client.last_received()))
fo.close()

client.service.Logout(wci)
print ("Logged out from " + SVC_URL + "... Bye bye.")

