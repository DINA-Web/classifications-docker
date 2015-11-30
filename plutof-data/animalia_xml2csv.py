# -*- coding: utf-8 -*-
"""
@author: markus
"""
import xml.etree.cElementTree as cElementTree

RLI_XML = "boho.xml"
RLI_CSV = "boho.csv"
global count
count = 0
global tids 
tids = []

def ns_tag(tag):
  return str(cElementTree.QName('http://schemas.datacontract.org/2004/07/ArtDatabanken.WebService.Data', tag))

print "Starting to convert " + RLI_XML + " to " + RLI_CSV
fo = open(RLI_CSV, "w")
fo.write("row_no, category_id, dyntaxa_id,common,scientific\n")
for event, elem in cElementTree.iterparse(RLI_XML):
  #print elem.tag 
  if elem.tag == ns_tag("Taxon"):
    tid = elem.findtext(ns_tag("Id")) or ""    
    common = elem.findtext(ns_tag("CommonName")) or ""
    scientific = elem.findtext(ns_tag("ScientificName")) or ""
    category = elem.findtext(ns_tag("CategoryId")) or ""
    count += 1
    row = str(count) + "," + category + "," + tid + "," + \
      common + "," + scientific + "\n"
    fo.write(row.encode("utf8"))
    if category == "2":
      tids.append(tid)
fo.close()
print " ".join(tids)
print "Done."
