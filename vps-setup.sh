#!/bin/bash

echo "Username"
read USERNAME

echo "SSH Public Key"
read SSHPUBKEY

apt-get update && apt-get -y dist-upgrade

apt-get install -y bash-completion nano fail2ban sshguard unzip curl wget apt-transport-https ca-certificates software-properties-common git htop

adduser --disabled-password --gecos "" $USERNAME
usermod -aG sudo $USERNAME

mkdir /home/$USERNAME/.ssh
touch /home/$USERNAME/.ssh/authorized_keys
echo "$SSHPUBKEY" >> /home/$USERNAME/.ssh/authorized_keys
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh/

#disable root login
#cp /etc/ssh/sshd_config .
sed -i -e "s/PermitRootLogin yes/PermitRootLogin no/g" /etc/ssh/sshd_config

#enable user login
echo "AllowUsers $USERNAME" >> /etc/ssh/sshd_config

#disable sudo password prompt
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

#add swap space
sudo fallocate -l 4G /swapfile && chmod 600 /swapfile && mkswap /swapfile && swapon /swapfile && echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab && free -h

sudo sysctl vm.swappiness=50
sudo sysctl vm.vfs_cache_pressure=50

sudo echo "vm.swappiness = 50" >>/etc/sysctl.conf
sudo echo "vm.vfs_cache_pressure = 50" >>/etc/sysctl.conf

export LC_ALL="en_US.UTF-8"

echo "restarting ssh"
service ssh restart

echo "Reboot"

exit

