#!/bin/bash

set -ex

function usage {
    echo -e "\nUSAGE: ./build-release.sh [release DOCKER_REPO DOCKER_USER DOCKER_PASSWORD]"
    echo -e "\n    release          Specifying \"release\" instructs the script to build the Docker image and push it to a remote repository"
    echo -e "    DOCKER_REPO      The name of the repository in Docker hub or address of private repository server"
    echo -e "    DOCKER_USER      User name to login as to the remote repository"
    echo -e "    DOCKER_PASSWORD  The users password\n"
    exit 1
}

case $1 in
help)
    usage
    ;;
*)
    [[ $# -eq 0 ]] || usage
    ;;
esac

TAG="$(git tag -l --points-at HEAD)"
if [[ "$1" == "release" ]] && [[ -z "$TAG" ]] ; then
    echo "To build and push the release image their must be a version tag at the head of the branch."
    exit 1
fi

docker ps -a | awk '/^[0-9a-f]/{ print $1 }' | xargs docker rm -f
docker rmi vpn-server
docker build . -t vpn-server

if [[ -n $TAG && -n $3 && -n $4 ]]; then
    docker login -u $3 -p $4

    docker tag vpn-server $2/vpn-server:latest
    docker tag vpn-server $2/vpn-server:$TAG
    docker push $2/vpn-server

    # clean up
    docker rmi $2/vpn-server:latest
    docker rmi $2/vpn-server:$TAG
    docker rmi vpn-server
fi
