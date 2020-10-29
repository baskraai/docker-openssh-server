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
    docker tag openssh-server baskraai/openssh-server:stable
    echo "# pushing stable version to Docker Hub"
    docker push baskraai/openssh-server:stable
elif [ "$TRAVIS_BRANCH" == "testing" ]; then
    docker tag openssh-server baskraai/openssh-server:testing
    echo "# pushing testing version to Docker Hub"
    docker push baskraai/openssh-server:testing
else
    echo "! Error, branch may not be build."
    echo "$TRAVIS_BRANCH"
    exit 1
fi

exit 0
