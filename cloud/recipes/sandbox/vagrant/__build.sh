#!/bin/bash

target_os=${1:-}
target_arch=${2:-}
cookbook_version=${3:-}

recipe_dir=$(cd $(dirname $BASH_SOURCE) && pwd)

set -xeuo pipefail

download_dir=`mktemp -d`

if [[ $cookbook_version == dev ]]; then
  curl -f -s \
    -L https://mycsdev-deploy-artifacts.s3.amazonaws.com/releases/mycs-cookbook-utils_${target_os}_${target_arch}.zip \
    -o ${download_dir}/mycs-cookbook-utils.zip
else
  curl -f -s \
    -L https://mycsprod-deploy-artifacts.s3.amazonaws.com/releases/mycs-cookbook-utils-${cookbook_version}_${target_os}_${target_arch}.zip \
    -o ${download_dir}/mycs-cookbook-utils.zip
fi
cd ${download_dir}
unzip ./mycs-cookbook-utils.zip
cd -

for f in $(find $recipe_dir -maxdepth 1 -type l -ls | awk '/\/..\/.build\/bin\//{ print $11 }'); do
  fname=$(basename $f)
  mv ${download_dir}/${fname} ${recipe_dir}/${fname}
done

rm -fr $download_dir
