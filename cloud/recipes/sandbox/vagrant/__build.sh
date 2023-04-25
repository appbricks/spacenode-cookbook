#!/bin/bash

target_os=${1:-}
target_arch=${2:-}
cookbook_version=${3:-}

set -xeuo pipefail

download_dir=`mktemp -d`

if [[ $cookbook_version == dev ]]; then

else

fi

rm -fr $download_dir
