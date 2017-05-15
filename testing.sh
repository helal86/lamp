#!/bin/bash

# Update the packages.
apt-get update
apt-get -y upgrade

# Install a few utility tools.
apt-get install -y tar wget git

# Add repositories
add-apt-repository -y ppa:openjdk-r/ppa

apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)

echo "deb http://repos.mesosphere.com/${DISTRO} ${CODENAME} main" | 
  sudo tee /etc/apt/sources.list.d/mesosphere.list

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

# Final apt-get update before installing packages
apt-get update


# Install JDK
apt-get -y install openjdk-8-jdk-headless

# Install autotools (Only necessary if building from git repository).
apt-get -y install autoconf libtool

# Install other Mesos dependencies.
apt-get -y install apt-transport-https ca-certificates curl build-essential python-dev python-virtualenv libcurl4-nss-dev libsasl2-dev libsasl2-modules maven libapr1-dev libsvn-dev htop python-pip=1.5.4-1ubuntu4 maven=3.0.5-1 ntp docker-ce libwww-perl libdatetime-perl unzip monit=1:5.6-2  software-properties-common

# Install packages
sudo apt-get -y install mesos marathon 

# Install python pip packages
pip install urllib3 boto3 pyopenssl ndg-httpsclient pyasn1 

# install mesos config files

 curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-03-01" | grep ipaddress


