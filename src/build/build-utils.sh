#!/bin/bash

action=${1:-}
os=${2:-}
arch=${3:-}

set -xeuo pipefail

root_dir=$(cd $(dirname $BASH_SOURCE)/../.. && pwd)

build_dir=${root_dir}/.build
rm -fr ${build_dir}/bin

if [[ $action == *:clean-all:* ]]; then
  # remove all build artifacts
  # and do a full build
  rm -fr ${build_dir}
fi
release_dir=${build_dir}/releases
mkdir -p ${release_dir}

build_os=$(go env GOOS)
build_arch=$(go env GOARCH)

function build() {

  local os=$1
  local arch=$2
  local srcpath=$3
  local outfile=$4
  local build_version=$5
  local build_timestamp=$6

  if [[ $os == windows ]]; then
    outfile="${outfile}.exe"
  fi

  # build and package release binary
  mkdir -p ${release_dir}/${os}_${arch}
  pushd ${release_dir}/${os}_${arch}

  local out_dir=$(dirname $srcpath)/.out
  mkdir -p $out_dir
  pushd $out_dir

  versionFlags="-X \"appbricks.io/mycs-cookbook-utils/internal.Version=$build_version\" -X \"appbricks.io/mycs-cookbook-utils/internal.BuildTimestamp=$build_timestamp\""
  
  if [[ $action == *:dev:* ]]; then
    GOOS=$os GOARCH=$arch go build -ldflags "$versionFlags" -o $outfile $srcpath
  else
    if [[ $build_os == linux ]]; then
      GOOS=$os GOARCH=$arch CGO_ENABLED=0 go build -ldflags "-s -w $versionFlags" -o $outfile $srcpath
    else
      GOOS=$os GOARCH=$arch go build -ldflags "-s -w $versionFlags" -o $outfile $srcpath
    fi
  fi
  mv $out_dir/* ${release_dir}/${os}_${arch}

  popd
  rm -fr $out_dir

  zip -ru ${release_dir}/mycs-cookbook-utils_${os}_${arch}.zip .
  popd
}

if [[ $action == *:dev:* ]]; then
  # build binary for a dev environment
  build_version=dev
  build_timestamp=$(date +'%B %d, %Y at %H:%M %Z')

  os=$build_os
  arch=$build_arch
  for srcpath in $(find ${root_dir}/src/utils/cmd/* -type d -print); do 
    build "$os" "$arch" \
      "${srcpath}" \
      $(basename $srcpath) \
      "$build_version" "$build_timestamp"
  done

else
  # set version
  tag=${GITHUB_REF/refs\/tags\//}
  build_version=${tag:-0.0.0}
  build_timestamp=$(date +'%B %d, %Y at %H:%M %Z')

  # build release binaries for all supported architectures
  if [[ -n $os && -n $arch ]]; then
    for srcpath in $(find ${root_dir}/src/utils/cmd/* -type d -print); do 
      build "$os" "$arch" \
        "${srcpath}" \
        $(basename $srcpath) \
        "$build_version" "$build_timestamp"
    done
  else
    echo "Target OS and ARCH arguments missing."
    exit 1
  fi
fi

ln -s ${release_dir}/${build_os}_${build_arch} ${build_dir}/bin
