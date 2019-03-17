#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

##########################################################################
# Docker image requirements
##########################################################################
apt-get update -y
apt-get -y --no-install-recommends install dbus apt-utils locales tzdata \
    curl gnupg gcc g++ make wget apt-transport-https build-essential nano \
    ca-certificates libssl-dev net-tools zip unzip software-properties-common

service dbus start

##########################################################################
# Time zone
##########################################################################
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

##########################################################################
# Configure locales
##########################################################################
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
update-locale LC_ALL=en_US.UTF-8
update-locale LANGUAGE=en_US:en

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en

##########################################################################
# User / Group
##########################################################################
groupadd fcgibench
useradd fcgibench -s /bin/bash -m -g fcgibench -G fcgibench
chown -R fcgibench:fcgibench /var/fcgibench/

##########################################################################
# nginx
##########################################################################
apt-get install -y --no-install-recommends nginx apache2-utils
service nginx stop
cp -f /var/fcgibench/nginx/default.conf /etc/nginx/sites-available/default

##########################################################################
# NodeJS
##########################################################################
curl -sL https://deb.nodesource.com/setup_11.x | bash -
apt-get install -y --no-install-recommends nodejs
su fcgibench -c "cd /var/fcgibench/nodejs; npm install"

##########################################################################
# Mono
##########################################################################
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb https://download.mono-project.com/repo/ubuntu stable-bionic main" \
    | tee /etc/apt/sources.list.d/mono-official-stable.list
apt-get update -y
apt-get install -y --no-install-recommends mono-devel ca-certificates-mono nuget
su fcgibench -c "cd /var/fcgibench/csharp; nuget install FastCGI; cp FastCGI.*/lib/net*/FastCGI.dll ./"
rm -r /var/fcgibench/csharp/*/
su fcgibench -c "cd /var/fcgibench/csharp; mcs -out:fcgi.exe -r:FastCGI.dll main.cs"

add-apt-repository universe
apt-get install apt-transport-https
apt-get update
apt-get install dotnet-sdk-2.2
