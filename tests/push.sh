#!/bin/bash
echo "# Login"
login=$(echo "$DOCKERHUB_PASSWORD" | docker login -u "$DOCKERHUB_USERNAME" --password-stdin)
if [ "$?" != 0 ]; then
    echo "! Error, login not succesful"
    echo "$login"
    exit 1
else
    echo "# Docker Hub login succesful"
fi

if [ "$TRAVIS_BRANCH" == "master" ] || [ "$TRAVIS_BRANCH" == "main" ]; then
    docker tag openssh-server gamebase/openssh-server
    echo "# pushing latest version to Docker Hub"
    docker tag openssh-server gamebase/openssh-server:stable
    echo "# pushing stable version to Docker Hub"
elif [ "$TRAVIS_BRANCH" == "testing" ]; then
    docker tag openssh-server gamebase/openssh-server:testing
    echo "# pushing testing version to Docker Hub"
else
    echo "! Error, branch may not be build."
    echo "$TRAVIS_BRANCH"
    exit 1
fi

exit 0