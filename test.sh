#!/bin/bash -ex

apt-get update
apt-get install -y unzip

curl -LO https://github.com/balena-io/balena-cli/releases/download/v11.13.1/balena-cli-v11.13.1-linux-x64-standalone.zip

unzip *.zip

export ROOT=$(pwd)
export PATH=${ROOT}/balena-cli:${PATH}

balena login --token "${BALENA_TOKEN}"

balena os download fincm3 -o ${ROOT}/balena.img --version 2.29.2+rev2
balena os configure ${ROOT}/balena.img --app nathantest --device-type fincm3 --config config.json
export DEBUG=1
balena preload ${ROOT}/balena.img --app nathantest --commit 155d63d3dafdc300171ada4c961ce40b

echo "SUCCESS!"
