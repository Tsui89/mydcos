#!/bin/bash
yum -y install docker
systemctl stop firewalld && systemctl disable firewalld
service docker restart
docker load -i ng.tar.gz
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
