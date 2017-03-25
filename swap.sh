#!/bin/bash

sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

sudo echo "/swapfile   none    swap    sw    0   0" >> /etc/fstab

sudo sysctl vm.swappiness=50
sudo sysctl vm.vfs_cache_pressure=50

sudo echo "vm.swappiness = 50" >>/etc/sysctl.conf
sudo echo "vm.vfs_cache_pressure = 50" >>/etc/sysctl.conf

free -m

exit

