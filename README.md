# Overview

This is a example of building a Ubuntu image inside of OpenShift and then running the new image. This guide assumes you are using a Linux shell and have a OpenShift evironment available to use with the docker build strategy enabled.

# Ubuntu Docker Image build

Docker image we are building from

```
docker.io/ubuntu:16.04
```

Clone this repository
```
# clone this repository
git clone https://github.com/ctornatta/ocp-ubuntu-docker-build.git

# change directory to the cloned repository.
cd ocp-ubuntu-docker-build
```

As a non-privileged user, create a OpenShift project and image stream pointing to the Ubuntu image

```
# Create the project
oc new-project ubuntu-docker-build


# Create an image stream pointing to the Ubuntu image in Docker Hub
oc create -f -<<EOF
{
    "kind": "ImageStream",
    "apiVersion": "v1",
    "metadata": {
        "name": "ubuntu",
        "annotations": {
            "description": "Ubuntu docker image"
        }
    },
    "spec": {
        "dockerImageRepository": "docker.io/ubuntu"
    }
}
EOF
```

alternatively you can use the following command.
```
oc create -f ./ubuntu-docker-io-image-stream.json
```

Import the 16.04 tags

```
oc import-image ubuntu:16.04
```

Ensure that you see tag data back
```
oc get is

NAME           DOCKER REPO        TAGS                            UPDATED
ubuntu-16-04   docker.io/ubuntu   15.10,14.10,13.10 + 2 more...   Less than a second ago
```

Create template
```
oc create -f ./docker-build-template.yaml
```

Using template create the Kubernetes objects within the project. Update parameter values as needed.

```
# Create application
oc new-app \
 --template='docker-build' \
 -p BUILD_IMAGE_NAME='ubuntu-image' \
 -p GIT_URI='https://github.com/ctornatta/ocp-ubuntu-docker-build.git' \
 -p FROM_IMAGESTREAM='ubuntu:16.04' \
 -p IMAGESTREAM_NAMESPACE='ubuntu-docker-build'
```

Look at the logs
```
oc logs bc/ubuntu-image -f
```

Create a new app based off the example builder image
```
oc new-app -i ubuntu-image --name ubuntu-app
```

Tail the logs and you will see the output of the CMD `sh -c 'while true; do cat /etc/lsb-release;sleep 5; done'`

```
oc logs -f dc/ubuntu-app
```
You can make changes to the Dockerfile and do a binary build.
```
oc start-build bc/ubuntu-image --from-dir=.
```
