#!/bin/bash

build_script_path=$(dirname $BASH_SOURCE)

function usage {
  echo -e "\nUSAGE: ./build-release.sh [publish DOCKER_REPO DOCKER_USER DOCKER_PASSWORD]"
  echo -e "\n    publish          Specifying \"publish\" instructs the script to build the Docker image and push it to a remote repository"
  echo -e "    DOCKER_REPO      The name of the repository in Docker hub or address of private repository server"
  echo -e "    DOCKER_USER      User name to login as to the remote repository"
  echo -e "    DOCKER_PASSWORD  The users password\n"
  exit 1
}

if [[ $1 == help ]]; then
  usage
  exit 0
fi

docker ps -a | awk '/^[0-9a-f]/{ print $1 }' | xargs docker rm -f
docker rmi vpn-server 2>&1 >/dev/null

set -e
# docker build . -t vpn-server

if [[ "$1" == "publish" ]]; then
  
  if [[ -n $2 && -n $3 && -n $4 ]]; then

    TAG=${TRAVIS_TAG:-$(git tag -l --points-at HEAD)}
    if [[ -z "$TAG" ]] ; then
      echo "To build and push the release image their must be a version tag at the head of the branch."
      exit 1
    fi

    # docker login -u $3 -p $4

    # docker tag vpn-server $2/vpn-server:latest
    # docker tag vpn-server $2/vpn-server:$TAG
    # docker push $2/vpn-server

    # # clean up
    # docker rmi $2/vpn-server:latest
    # docker rmi $2/vpn-server:$TAG
    # docker rmi vpn-server

    # Create installer scripts
    sed "s|appbricks/vpn-server:latest|appbricks/vpn-server:$TAG|" \
      ${build_script_path}/../install/install.sh > install.sh
    sed "s|appbricks/vpn-server:latest|appbricks/vpn-server:$TAG|" \
      ${build_script_path}/../install/install.ps1 > install.ps1

    if [[ -e ${build_script_path}/../../doc/release-notes-$TAG.md ]]; then
      cp ${build_script_path}/../../doc/release-notes-$TAG.md release-notes.md
    else
      cp ${build_script_path}/../../doc/release-notes.md release-notes.md
    fi
  else
    echo "To publish DOCKER_REPO, DOCKER_USER and DOCKER_PASSWORD arguments are required."
    exit 1
  fi  
fi
