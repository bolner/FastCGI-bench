#!/usr/bin/env bash

service dbus start

##########################################################################
# NodeJS
##########################################################################
su fcgibench -c "node /var/fcgibench/nodejs/index.js 8080 &"
su fcgibench -c "node /var/fcgibench/nodejs/index.js 8081 &"
su fcgibench -c "node /var/fcgibench/nodejs/index.js 8082 &"
su fcgibench -c "node /var/fcgibench/nodejs/index.js 8083 &"

##########################################################################
# C#
##########################################################################
su fcgibench -c "mono /var/fcgibench/csharp/fcgi.exe 9090 &"
su fcgibench -c "mono /var/fcgibench/csharp/fcgi.exe 9091 &"
su fcgibench -c "mono /var/fcgibench/csharp/fcgi.exe 9092 &"
su fcgibench -c "mono /var/fcgibench/csharp/fcgi.exe 9093 &"

service nginx start

while true; do sleep infinity; done
