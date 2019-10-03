#!/bin/sh -ex

# we are inside the dind container, starting up a local dockerd
nohup dockerd 2>&1 &
sleep 5  # wait for dockerd to spin up fully

export DOCKER_HOST=unix:///var/run/docker.sock

cd /workspace


docker build -t inner-container:latest -f Dockerfile.inner .
docker run --privileged inner-container:latest
