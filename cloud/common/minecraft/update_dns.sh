#!/bin/bash

ip=$(ip a | grep -A 2 '^2:' | awk '/inet/{ split($2,ip,"/"); print ip[1] }')

set +e
read -r -d '' setRecordBody << EOM
{
  "rrsets": [ {
    "name": "${mc_dns_name}.", 
    "type": "A", 
    "changetype": "REPLACE", 
    "ttl": 300, 
    "records": [ {
      "content": "$ip", 
      "disabled": false, 
      "name": "${mc_dns_name}", 
      "ttl": 300, 
      "type": "A", 
      "priority": 0 
    } ] 
  } ] 
}
EOM
set -e

curl -s -X PATCH ${pdns_url}/api/v1/servers/localhost/zones/local \
  -H 'X-API-Key: ${pdns_api_key}' \
  --data "$setRecordBody"
