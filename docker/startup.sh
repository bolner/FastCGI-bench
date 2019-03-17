#!/usr/bin/env bash

service dbus start

##########################################################################
# NodeJS
# Nginx URL: http://127.0.0.1/nodejs
##########################################################################
su fcgibench -c "cd /var/fcgibench/NodeJS; node index.js 7070 &"
su fcgibench -c "cd /var/fcgibench/NodeJS; node index.js 7071 &"
su fcgibench -c "cd /var/fcgibench/NodeJS; node index.js 7072 &"
su fcgibench -c "cd /var/fcgibench/NodeJS; node index.js 7073 &"

##########################################################################
# AsyncFastCGI
# Nginx URL: http://127.0.0.1/asyncfastcgi
##########################################################################
AFCGI_PATH="/var/fcgibench/AsyncFastCGI/bin/Release/netcoreapp2.2/ubuntu.18.04-x64/"

su fcgibench -c "cd ${AFCGI_PATH}; dotnet exec AsyncFastCGI.dll 8080 &"
sleep 1
su fcgibench -c "cd ${AFCGI_PATH}; dotnet exec AsyncFastCGI.dll 8081 &"
sleep 1
su fcgibench -c "cd ${AFCGI_PATH}; dotnet exec AsyncFastCGI.dll 8082 &"
sleep 1
su fcgibench -c "cd ${AFCGI_PATH}; dotnet exec AsyncFastCGI.dll 8083 &"

##########################################################################
# LukasBoersma/FastCGI
# Nginx URL: http://127.0.0.1/lbfastcgi
##########################################################################
LBFCGI_PATH="/var/fcgibench/LbFastCGI/bin/Release/netcoreapp2.2/ubuntu.18.04-x64/"

su fcgibench -c "cd ${LBFCGI_PATH}; dotnet exec LbFastCGI.dll 9090 &"
sleep 1
su fcgibench -c "cd ${LBFCGI_PATH}; dotnet exec LbFastCGI.dll 9091 &"
sleep 1
su fcgibench -c "cd ${LBFCGI_PATH}; dotnet exec LbFastCGI.dll 9092 &"
sleep 1
su fcgibench -c "cd ${LBFCGI_PATH}; dotnet exec LbFastCGI.dll 9093 &"

service nginx start

while true; do sleep infinity; done
