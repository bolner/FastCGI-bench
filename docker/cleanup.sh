#!/usr/bin/env bash

docker stop fcgibench 2>/dev/null 2>&1
docker image rm fcgibench --force
docker system prune --force
