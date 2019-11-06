#!/bin/bash

build_script_path=$(dirname $BASH_SOURCE)
set -e

if [[ -n "$TRAVIS_TAG" ]]; then
    echo "Git commit is in master branch and has a commit tag - building and publishing the docker image..."
    ${build_script_path}/build-release.sh publish $DOCKER_REPO $DOCKER_USER $DOCKER_PASSWORD
elif [[ "$TRAVIS_BRANCH" != "master" ]]; then
    echo "Not a release commit. Validating docker container image build only..."
    ${build_script_path}/build-release.sh
else
    echo "Commit to master branch without tag. Skipping build..."
fi
