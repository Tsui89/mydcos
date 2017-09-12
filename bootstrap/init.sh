yum -y install docker
systemctl stop firewalld && systemctl disable firewalld
service docker restart
sed -i s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
reboot
