#!/bin/sh -e

if [ -z "${BALENA_TOKEN}" ]; then
  echo "BALENA_TOKEN unset"
  exit 1
fi

set -x

# we are inside the dind container, starting up a local dockerd
nohup dockerd 2>&1 &
sleep 5  # wait for dockerd to spin up fully

export DOCKER_HOST=unix:///var/run/docker.sock

cd /workspace


apk --no-cache add ca-certificates wget libstdc++6 gcompat libc6-compat unzip curl gcompat npm

curl -sLO http://artifacts.oden.io/resin/balena-cli.tar.gz
tar zxf balena-cli.tar.gz

export ROOT=$(pwd)
export PATH=${ROOT}/balena-cli/bin/:${PATH}


balena login --token "${BALENA_TOKEN}"
balena os download fincm3 -o ${ROOT}/balena.img --version 2.29.2+rev2
balena os configure ${ROOT}/balena.img --app nathantest --device-type fincm3 --config config.json

docker run hello-world
export DEBUG=1
balena preload --docker /var/run/docker.sock ${ROOT}/balena.img --app nathantest --commit 155d63d3dafdc300171ada4c961ce40b
