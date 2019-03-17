#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive

##########################################################################
# Docker image requirements
##########################################################################
apt-get update -y
apt-get -y --no-install-recommends install dbus apt-utils locales tzdata git \
    curl gnupg gcc g++ make wget apt-transport-https build-essential nano psmisc \
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
# Nginx
##########################################################################
apt-get install -y --no-install-recommends nginx apache2-utils
service nginx stop
cp -f /var/fcgibench/nginx/default.conf /etc/nginx/sites-available/default

##########################################################################
# NodeJS
##########################################################################
curl -sL https://deb.nodesource.com/setup_11.x | bash -
apt-get install -y --no-install-recommends nodejs
su fcgibench -c "cd /var/fcgibench/NodeJS; npm install"

##########################################################################
# .NET Core
##########################################################################

wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

add-apt-repository universe
apt-get install -y --no-install-recommends apt-transport-https
apt-get update
apt-get install -y --no-install-recommends dotnet-sdk-2.2 nuget

rm -f packages-microsoft-prod.deb

# FbFastCGI
su fcgibench -c "cd /var/fcgibench/LbFastCGI; dotnet publish -c Release -r ubuntu.18.04-x64"

# AsyncFastCGI.NET (no NuGet yet)
su fcgibench -c "cd /var/fcgibench/AsyncFastCGI; mkdir git; cd git; git clone 'https://github.com/bolner/AsyncFastCGI.NET.git' ./"
su fcgibench -c "cd /var/fcgibench/AsyncFastCGI; rm -fr lib 2>/dev/null; mv git/lib ./; rm -fr git"
su fcgibench -c "cd /var/fcgibench/AsyncFastCGI; dotnet publish -c Release -r ubuntu.18.04-x64"
