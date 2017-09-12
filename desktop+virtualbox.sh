yum groupinstall "GNOME Desktop" "Graphical Administration Tools"
ln -sf /lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
reboot





cat /etc/yum.repos.d/virtualbox.repo
```
[virtualbox]
name=Oracle Linux / RHEL / CentOS-$releasever / $basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/el/$releasever/$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc
```
yum clean all
yum makecache
yum -y install VirtualBox-5.1.x86_64
yum install gcc make
yum install kernel-devel-3.10.0-514.el7.x86_64

/sbin/vboxconfig
