#!/bin/bash

# SLAVE INSTALL #

# Update the packages.
apt-get update

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


#get ip address

master1ip="$(getent hosts master1 | awk '{ print $1 }')"
master2ip="$(getent hosts master2 | awk '{ print $1 }')"
master3ip="$(getent hosts master3 | awk '{ print $1 }')"

echo "zk://"$master1ip":2181,"$master2ip":2181,"$master3ip":2181/mesos" > /mnt/zk
cp /mnt/zk /etc/mesos/

sudo restart zookeeper
sudo start mesos-master
sudo start marathon

#get ip address

slaveip="$(ifconfig | grep -A 1 'eth0' | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)"

sudo stop zookeeper
echo manual | sudo tee /etc/init/zookeeper.override

echo manual | sudo tee /etc/init/mesos-master.override
sudo stop mesos-master

echo "$slaveip" | sudo tee /etc/mesos-slave/ip
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname

sudo start mesos-slave


sudo apt-get install -y python2.7 wget
sudo apt-get -y install libcurl4-nss-dev
wget -c https://apache.bintray.com/aurora/ubuntu-trusty/aurora-executor_0.17.0_amd64.deb
sudo dpkg -i aurora-executor_0.17.0_amd64.deb

sudo sh -c 'echo "MESOS_ROOT=/tmp/mesos" >> /etc/default/thermos'

wget -c https://apache.bintray.com/aurora/ubuntu-trusty/aurora-tools_0.17.0_amd64.deb
sudo dpkg -i aurora-tools_0.17.0_amd64.deb
