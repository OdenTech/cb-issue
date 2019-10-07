#!/bin/sh -ex

# we are inside the dind container, starting up a local dockerd
nohup dockerd 2>&1 &
sleep 5  # wait for dockerd to spin up fully

export DOCKER_HOST=unix:///var/run/docker.sock

cd /workspace

dd if=/dev/zero of=/workspace/disk.img bs=1k count=1000

docker build -t inner-container:latest -f Dockerfile.inner .
docker run --rm --privileged -v /workspace/disk.img:/mnt/disk.img inner-container:latest
