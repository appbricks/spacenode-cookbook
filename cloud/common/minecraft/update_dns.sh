#!/bin/bash

ip=$(ip a | grep -A 6 '^2:' | awk '/inet /{ split($2,ip,"/"); print ip[1] }')

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

curl -s -f -X PATCH ${pdns_url}/api/v1/servers/localhost/zones/${dns_zone} \
  -H 'X-API-Key: ${pdns_api_key}' \
  --data "$setRecordBody"

while [[ $? -ne 0 ]]; do
  echo "Waiting for DNS API endpoint to become available..."
  sleep 5

  curl -s -f -X PATCH ${pdns_url}/api/v1/servers/localhost/zones/${dns_zone} \
    -H 'X-API-Key: ${pdns_api_key}' \
    --data "$setRecordBody"
done
set -e
