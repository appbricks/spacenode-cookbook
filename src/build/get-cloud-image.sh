#!/bin/bash

# Determine MyCS bastion image for environment
# (NOTE: this needs to be rethought)
images=$(aws ec2 describe-images --output json \
  --region us-east-1 --filters "Name=name,Values=appbricks-bastion*")

if [[ $1 == prod ]]; then
  prod_images=$(echo "$images" | jq '[.Images[] | select(.Name|test("appbricks-bastion_\\d+\\.\\d+\\.\\d+"))'])
  appbricks_cloud_image=$(echo "$prod_images" | jq -r 'sort_by(.Name | split("_")[1] | split(".") | map(tonumber))[-1] | .Name')

else
  dev_images=$(echo "$images" | jq '[.Images[] | select(.Name|test("appbricks-bastion_D.*"))]')
  appbricks_cloud_image=$(echo "$dev_images" | jq -r 'sort_by(.Name | split("_D.")[1] | split(".") | map(tonumber))[-1] | .Name')
fi

echo $appbricks_cloud_image
