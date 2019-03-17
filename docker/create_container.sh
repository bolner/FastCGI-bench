#!/usr/bin/env bash

if [[ $# -lt 1 ]]; then
    printf "\nPlease specify a port.\n\n" 1>&2
    exit 1
fi

HOST_PORT=$1
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

docker run -d --restart unless-stopped -h fcgibench -p ${HOST_PORT}:80 -v ${DIR}:/var/fcgibench --name fcgibench fcgibench
