#!/bin/bash

build_script_path=$(dirname $BASH_SOURCE)
set -e

env

if [[ -n "$TRAVIS_BRANCH" == "master" && -n "$TRAVIS_TAG" ]]; then
    echo "Git commit is in master branch and has a commit tag - building and publishing the docker image..."
    {build_script_path}/build-release.sh publish $DOCKER_REPO $DOCKER_USER $DOCKER_PASSWORD
else
    echo "Not a release commit. Validating docker container image build only..."
    {build_script_path}/build-release.sh
fi
