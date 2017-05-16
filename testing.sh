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
#pip install urllib3 boto3 pyopenssl ndg-httpsclient pyasn1 

# install mesos config files

 curl -H Metadata:true "http://169.254.169.254/metadata/instance?api-version=2017-03-01" | grep ipaddress

## mesos config

sleep 45

#get ip address

master1ip="$(getent hosts master1 | awk '{ print $1 }')"
master2ip="$(getent hosts master2 | awk '{ print $1 }')"
master3ip="$(getent hosts master3 | awk '{ print $1 }')"

echo $master1ip
echo $master2ip
echo $master3ip


echo "zk://"$master1ip":2181,"$master2ip":2181,"$master3ip":2181/mesos" > /mnt/zk
cp /mnt/zk /etc/mesos/

#check hostname
vmname="$(getent hosts master1 | awk '{ print $2 }')"

if [[ $vmname ==  *"master1"* ]]; then
        echo "1" > /mnt/myid;
        echo $master1ip | sudo tee /mnt/ip
elif [[ $vmname ==  *"master2"* ]]; then
        echo "2" > /mnt/myid;
        echo $master2ip | sudo tee /mnt/ip
else 	echo "3" > /mnt/myid;
		echo $master3ip | sudo tee /mnt/ip
fi

cp /mnt/myid /etc/zookeeper/conf/
cp /mnt/ip /etc/mesos-master/

cp /etc/zookeeper/conf/zoo.cfg /mnt/zoo.cfg

#add to zoo.cfg
echo "server.1="$master1ip":2888:3888
server.2="$master2ip":2888:3888
server.3="$master3ip":2888:3888" >> /mnt/zoo.cfg

cp /mnt/zoo.cfg /etc/zookeeper/conf/

#add quorum
echo "2" > /etc/mesos-master/quorum

#mesos config files
cp /etc/mesos-master/ip /etc/mesos-master/hostname
mkdir -p /etc/marathon/conf
cp /etc/mesos-master/hostname /etc/marathon/conf
cp /etc/mesos/zk /etc/marathon/conf/master
cp /etc/marathon/conf/master /etc/marathon/conf/zk

#add marathon addresses
echo "zk://"$master1ip":2181,"$master2ip":2181,"$master3ip":2181/marathon" > /mnt/zk
cp /mnt/zk /etc/marathon/conf/

stop mesos-slave
echo manual | sudo tee /etc/init/mesos-slave.override

sudo restart zookeeper
sudo start mesos-master
sudo start marathon
