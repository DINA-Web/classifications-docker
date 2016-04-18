#!/bin/bash

echo "Request oauth2 token"
TOKEN=$(curl -X POST -d "grant_type=password&username=admin&password=password12" \
	-u"a27a3bc616b1ed2ff965:9174b76bcba9ab2188ada16bd6eb7166d2b3c71b" \
	http://localhost:7000/oauth2/access_token/ -s | tac | tac | \
	grep -P -o 'access_token.*?[[:alnum:]]{40}' | grep -P -o "[[:alnum:]]{40}")

echo "Got token $TOKEN"

echo "Creating tree to hold Dyntaxa data"
curl -X POST -q -s -H "Authorization: Bearer $TOKEN" http://localhost:7000/api/taxonomy/tree/ --data "name=dyntaxa" | json_pp
curl -q -s -H "Authorization: Bearer $TOKEN" http://localhost:7000/api/taxonomy/tree/ | json_pp

