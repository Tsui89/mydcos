#!/bin/bash
yum install -y docker
echo '{"storage-driver":"overlay"}' > /etc/docker/daemon.json
systemctl enable docker
systemctl start docker
systemctl stop firewalld && systemctl disable firewalld
#vi /etc/selinux/config
groupadd docker
groupadd nogroup
yum install -y unzip
yum install -y ntp
yum install -y bind-utils
systemctl enable ntpd
systemctl start ntpd
timedatectl set-ntp true
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config

#"storage-driver":"overlay"

kill -9 `pidof dnsmasq`
