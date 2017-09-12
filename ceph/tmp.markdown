
ALEX JOH'S BLOG
I like this comment, "Great companies don't hire skilled people and motivate them, they hire already motivated people and inspire them"


SEARCH

Install Ceph shared storage to DCOS 1.9
June 26, 2017
Adding shared storage to DC/OS with ceph

After installing DC/OS, I noticed that all data worked with container stored to local node. Due to the reason, when the container was moved from one node to antoher, all configuration has been lost. I tried to find out shared storage solution and this manual is regarding how to add CEPH open source platform to CentOS DC/OS platform

Reference

Ceph Script on DC/OS
Ceph on DC/OS
losetup manual
Checking file system type in Linux
Ceph example from DCOS 1.8
Ceph example from DCOS 1.9
bash_rc vs profile
Install lightttpd
rbd-docker-plugin
Current configuration

As I posted from previous DC/OS blog, my configuration is

I used 4 nodes as DC/OS recommended

ComputerName	IP Addess	Computer Spec	Description	Note
dcostest01	172.16.110.20	2 core, 16GB, 100 GB Disk	Bootstrap Computer	Ceph Client & DC/OS CLI will be in here
dcostest02	172.16.110.30	2 core, 16GB, 100 GB Disk	Agent1-Master
dcostest03	172.16.110.31	2 core, 16GB, 100 GB Disk	Agent1-Private Agent	OSD
dcostest04	172.16.110.32	2 core, 16GB, 100 GB Disk	Agent2-Private Agent	OSD
dcostest05	172.16.110.33	2 core, 16GB, 100 GB Disk	Agent3-Private Agent	OSD
dcostest06	172.16.110.34	2 core, 16GB, 100 GB Disk	Agent4-Private Agent	OSD
dcostest07	172.16.110.35	2 core, 16GB, 100 GB Disk	Agent5-Private Agent	OSD
dcostest08	172.16.110.36	2 core, 16GB, 100 GB Disk	Agent6-Private Agent	OSD
dcostest09	172.16.110.37	2 core, 16GB, 100 GB Disk	Agent1-Public Agent	Ceph Docker
For the monitor, you can install with odd numbers, but doesn't necessary to match with number of OSD. In our implementation, we will use 3 OSDs.

Adding disk to centOS

Someone wants to try with looped deivice, this is the steps to create looped device. However, this is not working correctly. Seems that Ceph doesn't like disks from loop devices
sudo su -
mkdir -p /dcos/volume0
dd if=/dev/zero of=/root/volume0.img bs=1M count=25000
losetup /dev/loop0 /root/volume0.img
mkfs -t xfs /dev/loop0
losetup -d /dev/loop0
echo "/root/volume0.img /dcos/volume0 auto loop 0 2" | sudo tee -a /etc/fstab
mount /dcos/volume0
mount | grep "/dcos/volume"
[dcosadmin@dcotest04 ~]$ sudo su -
mount /dcos/volume0Last login: Thu Apr 20 13:33:22 MDT 2017 on tty1
[root@dcotest04 ~]# mkdir -p /dcos/volume0
[root@dcotest04 ~]# dd if=/dev/zero of=/root/volume0.img bs=1M count=25000
25000+0 records in
25000+0 records out
26214400000 bytes (26 GB) copied, 292.119 s, 89.7 MB/s
[root@dcotest04 ~]# losetup /dev/loop0 /root/volume0.img
[root@dcotest04 ~]# mkfs -t xfs /dev/loop0
meta-data=/dev/loop0             isize=512    agcount=4, agsize=1600000 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=6400000, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=3125, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@dcotest04 ~]# losetup -d /dev/loop0
[root@dcotest04 ~]# echo "/root/volume0.img /dcos/volume0 auto loop 0 2" | sudo tee -a /etc/fstab
/root/volume0.img /dcos/volume0 auto loop 0 2
[root@dcotest04 ~]# mount /dcos/volume0
[root@dcotest04 ~]# mount | grep "/dcos/volume"
/root/volume0.img on /dcos/volume0 type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
Adding new harddisk on Centos

Adding new harddisk

[dcosadmin@dcotest03 ~]$ sudo su -
Last login: Thu Apr 20 13:28:57 MDT 2017 on tty1
[root@dcotest03 ~]# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sdb
[root@dcotest03 ~]# fdisk /dev/sdb
Welcome to fdisk (util-linux 2.23.2).

Changes will remain in memory only, until you decide to write them.
Be careful before using the write command.

Device does not contain a recognized partition table
Building a new DOS disklabel with disk identifier 0xd44d345a.

Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (63-41943039, default 63):
Using default value 63
Last sector, +sectors or +size{K,M,G} (63-41943039, default 41943039):
Using default value 41943039
Partition 1 of type Linux and of size 20 GiB is set

Command (m for help): w
The partition table has been altered!

Calling ioctl() to re-read partition table.
Syncing disks.
[root@dcotest03 ~]# ls /dev/sd*
/dev/sda  /dev/sda1  /dev/sda2  /dev/sdb  /dev/sdb1
[root@dcotest03 ~]#
Formatting and mount command

mkdir -p /dcos/volume0 mkfs -t xfs /dev/sdb1 echo "/dev/sdb1 /dcos/volume0 auto loop 0 2" | sudo tee -a /etc/fstab mount /dcos/volume0 mount | grep "/dcos/volume"

Output

[root@dcotest04 ~]# mkdir -p /dcos/volume0
[root@dcotest03 ~]# mkfs -t xfs /dev/sdb1
meta-data=/dev/sdb1              isize=512    agcount=4, agsize=1310718 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=5242872, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@dcotest03 ~]# echo "/dev/sdb1 /dcos/volume0 auto loop 0 2" | sudo tee -a /etc/fstab
/dev/sdb1 /dcos/volume0 auto loop 0 2
[root@dcotest03 ~]# mount /dcos/volume0
[root@dcotest03 ~]# mount | grep "/dcos/volume"
/dev/sdb1 on /dcos/volume0 type xfs (rw,relatime,seclabel,attr2,inode64,noquota)
[root@dcotest03 ~]#
Need to run above command to all Private agent which is 172.16.110.31 to 172.16.110.36

Preparing Node

I followed the instruction from Ceph Script on DC/OS and Ceph example from DCOS 1.9

To recognize the new disk from DC/OS, the private agents will be needed to restart

sudo systemctl stop dcos-mesos-slave sudo rm -f /var/lib/dcos/mesos-resources sudo rm -f /var/lib/mesos/slave/meta/slaves/latest sudo sudo /opt/mesosphere/bin/make_disk_resources.py /var/lib/dcos/mesos-resources sudo systemctl start dcos-mesos-slave sudo systemctl restart ntpd cat /var/lib/dcos/mesos-resources | grep volume journalctl -b | grep '/dcos/volume0' journalctl -b | tail

[dcosadmin@dcotest07 ~]$ sudo rm -f /var/lib/dcos/mesos-resources
[dcosadmin@dcotest07 ~]$ sudo rm -f /var/lib/mesos/slave/meta/slaves/latest
[dcosadmin@dcotest07 ~]$ sudo sudo /opt/mesosphere/bin/make_disk_resources.py /var/lib/dcos/mesos-resources
Looking for mounts matching pattern "on\s+(/dcos/volume\d+)\s+"
Found matching mounts : [('/dcos/volume0', 20336)]
ERROR: Missing key 'MESOS_WORK_DIR'
[dcosadmin@dcotest07 ~]$ sudo systemctl start dcos-mesos-slave
[dcosadmin@dcotest07 ~]$ sudo systemctl restart ntpd
[dcosadmin@dcotest07 ~]$ cat /var/lib/dcos/mesos-resources | grep volume
MESOS_RESOURCES='[{"name": "ports", "ranges": {"range": [{"begin": 1025, "end": 2180}, {"begin": 2182, "end": 3887}, {"begin": 3889, "end": 5049}, {"begin": 5052, "end": 8079}, {"begin": 8082, "end": 8180}, {"begin": 8182, "end": 32000}]}, "type": "RANGES"}, {"name": "disk", "scalar": {"value": 20336}, "type": "SCALAR", "role": "*", "disk": {"source": {"mount": {"root": "/dcos/volume0"}, "type": "MOUNT"}}}, {"name": "disk", "scalar": {"value": 47947}, "type": "SCALAR", "role": "*"}]'
[dcosadmin@dcotest07 ~]$ journalctl -b | grep '/dcos/volume0'
Jun 13 15:45:23 dcotest07.test.flairpackaging.com mesos-agent[22513]: Found matching mounts : [('/dcos/volume0', 20336)]
Jun 13 15:45:23 dcotest07.test.flairpackaging.com mesos-agent[22513]: Generated disk resources map: [{'name': 'disk', 'scalar': {'value': 20336}, 'type': 'SCALAR', 'role': '*', 'disk': {'source': {'mount': {'root': '/dcos/volume0'}, 'type': 'MOUNT'}}}, {'name': 'disk', 'scalar': {'value': 47947}, 'type': 'SCALAR', 'role': '*'}]
Jun 13 15:45:24 dcotest07.test.flairpackaging.com mesos-agent[22530]: ecs="0" --logging_level="INFO" --max_completed_executors_per_framework="150" --modules_dir="/opt/mesosphere/etc/mesos-slave-modules" --network_cni_config_dir="/opt/mesosphere/etc/dcos/network/cni" --network_cni_plugins_dir="/opt/mesosphere/active/cni/" --oversubscribed_resources_interval="15secs" --perf_duration="10secs" --perf_interval="1mins" --qos_correction_interval_min="0ns" --quiet="false" --recover="reconnect" --recovery_timeout="15mins" --registration_backoff_factor="1secs" --resources="[{"name": "ports", "ranges": {"range": [{"begin": 1025, "end": 2180}, {"begin": 2182, "end": 3887}, {"begin": 3889, "end": 5049}, {"begin": 5052, "end": 8079}, {"begin": 8082, "end": 8180}, {"begin": 8182, "end": 32000}]}, "type": "RANGES"}, {"name": "disk", "scalar": {"value": 20336}, "type": "SCALAR", "role": "*", "disk": {"source": {"mount": {"root": "/dcos/volume0"}, "type": "MOUNT"}}}, {"name": "disk", "scalar": {"value": 47947}, "type": "SCALAR", "role": "*"}]" --revocable_cpu_low_priority="true" --runtime_dir="/var/run/mesos" --sandbox_directory="/mnt/mesos/sandbox" --strict="true" --switch_user="true" --systemd_enable_support="true" --systemd_runtime_directory="/run/systemd/system" --version="false" --work_dir="/var/lib/mesos/slave"
Jun 13 15:45:24 dcotest07.test.flairpackaging.com mesos-agent[22530]: I0613 15:45:24.053716 22530 slave.cpp:541] Agent resources: ports(*):[1025-2180, 2182-3887, 3889-5049, 5052-8079, 8082-8180, 8182-32000]; disk(*)[MOUNT:/dcos/volume0]:20336; disk(*):47947; cpus(*):4; mem(*):14863
Install Ceph Framework

I tried to use command line to install Ceph as tutorial suggested, but I don't have good luck from that method. Keep failing to lauch service.

For me, I simply went to Universe->Packages and installed from there.

IntallCeph

Click Advanced

InstallCeph-Ceph

I don't know exact meaning of virtual host and how use it, so I leaved it as default.

InstallCeph-Network

However, if someone want to try with these script came from one of reference site, you can do it. To run this, go to the bootstrap node which has DC/OS CLI utility

This script is from first reference (2-ceph_boot.sh)

sudo su - dcos package install --yes marathon-lb default_if=$(ip route list | awk '/^default/ {print $5}') IP_ADDR=$( ifconfig $default_if|grep inet|awk -F ' ' '{print $2}'|sed -n 1p ) NETMASK=$( ifconfig $default_if|grep inet|awk -F ' ' '{print $4}'|sed -n 1p ) IFS=. read -r i1 i2 i3 i4 <<< "$IP_ADDR" IFS=. read -r m1 m2 m3 m4 <<< "$NETMASK" NETWORK=$( printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))" ) mask2cdr () { local x=${1##255.} set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})2 )) ${x%%.} x=${1%%$3} echo $(( $2 + (${#x}/4) )) } CDRMASK=$(mask2cdr $NETMASK) HOST_NETWORK=$NETWORK"/"$CDRMASK echo $HOST_NETWORK MESOS_ROLE="ceph-role" MESOS_PRINCIPAL="ceph-principal" MESOS_SECRET="" PUBLIC_NETWORK=$HOST_NETWORK CLUSTER_NETWORK=$HOST_NETWORK ZOOKEEPER="leader.mesos:2181" API_HOST="0.0.0.0" MESOS_MASTER="leader.mesos:5050" DOWNLOAD_URI="https://dl.bintray.com/vivint-smarthome/ceph-on-mesos/ceph-on-mesos-0.2.9.tgz"

rm -f ./ceph-dcos.json sudo cat >> ceph-dcos.json << 'EOF' { "id": "/ceph", "cmd": "cd /mnt/mesos/sandbox/ceph-on-mesos-\nbin/ceph-on-mesos --api-port=$PORT0", EOF sudo cat >> ceph-dcos.json << EOF "cpus": 0.3, "mem": 512, "disk": 0, "instances": 1, "env": { "MESOS_ROLE": "$MESOS_ROLE", "MESOS_PRINCIPAL": "$MESOS_PRINCIPAL", "PUBLIC_NETWORK": "$PUBLIC_NETWORK", "CLUSTER_NETWORK": "$CLUSTER_NETWORK", "ZOOKEEPER": "$ZOOKEEPER", "API_HOST": "$API_HOST", "MESOS_MASTER": "$MESOS_MASTER" }, "uris": ["$DOWNLOAD_URI"], "container": { "type": "DOCKER", "docker": { "image": "mesosphere/marathon:v1.3.3", "forcePullImage": false, "privileged": false, "network": "HOST" }, "volumes": [ { "containerPath": "/dev/random", "hostPath": "/dev/urandom", "mode": "RO" } ] }, "healthChecks": [ { "protocol": "TCP", "gracePeriodSeconds": 300, "intervalSeconds": 60, "timeoutSeconds": 20, "maxConsecutiveFailures": 3 } ], "upgradeStrategy": { "minimumHealthCapacity": 0, "maximumOverCapacity": 0 }, "labels": { "MARATHON_SINGLE_INSTANCE_APP": "true", "HAPROXY_GROUP": "external", "DCOS_SERVICE_NAME": "ceph", "DCOS_SERVICE_SCHEME": "http", "DCOS_SERVICE_PORT_INDEX": "0", "DCOS_PACKAGE_IS_FRAMEWORK": "false" }, "acceptedResourceRoles": [ "", "slave_public" ], "portDefinitions": [ { "protocol": "tcp", "port": 5000, "servicePort": 5000, "labels": { "VIP_0": "/ceph:5000" }, "name": "api" } ] } EOF

dcos marathon app add ./ceph-dcos.json

output

[dcosadmin@dcotest01 ceph]$ dcos package install --yes marathon-lb
{
local x=${1##*255.}
set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
x=${1%%$3*}
echo $(( $2 + (${#x}/4) ))
}
CDRMASK=$(mask2cdr $NETMASK)
HOST_NETWORK=$NETWORK"/"$CDRMASK
echo $HOST_NETWORK
MESOS_ROLE="ceph-role"
MESOS_PRINCIPAL="ceph-principal"
MESOS_SECRET=""
PUBLIC_NETWORK=$HOST_NETWORK
CLUSTER_NETWORK=$HOST_NETWORK
ZOOKEEPER="leader.mesos:2181"
API_HOST="0.0.0.0"
MESOS_MASTER="leader.mesos:5050"
DOWNLOAD_URI="https://dl.bintray.com/vivint-smarthome/ceph-on-mesos/ceph-on-mesos-0.2.9.tgz"

rm -f ./ceph-dcos.json
sudo cat >> ceph-dcos.json << 'EOF'
{
  "id": "/ceph",
  "cmd": "cd /mnt/mesos/sandbox/ceph-on-mesos-*\nbin/ceph-on-mesos --api-port=$PORT0",
EOF
sudo cat >> ceph-dcos.json << EOF
  "cpus": 0.3,
  "mem": 512,
  "disk": 0,
  "instances": 1,
  "env": {
    "MESOS_ROLE": "$MESOS_ROLE",
    "MESOS_PRINCIPAL": "$MESOS_PRINCIPAL",
    "PUBLIC_NETWORK": "$PUBLIC_NETWORK",
    "CLUSTER_NETWORK": "$CLUSTER_NETWORK",
    "ZOOKEEPER": "$ZOOKEEPER",
    "API_HOST": "$API_HOST",
    "MESOS_MASTER": "$MESOS_MASTER"
  },
  "uris": ["$DOWNLOAD_URI"],
  "container": {
    "type": "DOCKER",
    "docker": {
      "image": "mesosphere/marathon:v1.3.3",
      "forcePullImage": false,
      "privileged": false,
      "network": "HOST"
    },
    "volumes": [
      {
        "containerPath": "/dev/random",
        "hostPath": "/dev/urandom",
        "mode": "RO"
      }
    ]
  },
  "healthChecks": [
    {
      "protocol": "TCP",
      "gracePeriodSeconds": 300,
      "intervalSeconds": 60,
      "timeoutSeconds": 20,
      "maxConsecutiveFailures": 3
    }
  ],
  "upgradeStrategy": {
    "minimumHealthCapacity": 0,
    "maximumOverCapacity": 0
  },
  "labels": {
    "MARATHON_SINGLE_INSTANCE_APP": "true",
    "HAPROXY_GROUP": "external",
    "DCOS_SERVICE_NAME": "ceph",
    "DCOS_SERVICE_SCHEME": "http",
    "DCOS_SERVICE_PORT_INDEX": "0",
    "DCOS_PACKAGE_IS_FRAMEWORK": "false"
  },
  "acceptedResourceRoles": [
    "*",
    "slave_public"
  ],
  "portDefinitions": [
    {
      "protocol": "tcp",
      "port": 5000,
      "servicePort": 5000,
      "labels": {
        "VIP_0": "/ceph:5000"
      },
      "name": "api"
    }
  ]
}
EOF

dcos marathon app add ./ceph-dcos.json
We recommend at least 2 CPUs and 1GiB of RAM for each Marathon-LB instance.

*NOTE*: ```Enterprise Edition``` DC/OS requires setting up the Service Account in all security modes.
Follow these instructions to setup a Service Account: https://docs.mesosphere.com/administration/id-and-access-mgt/service-auth/mlb-auth/
Installing Marathon app for package [marathon-lb] version [1.7.0]
Marathon-lb DC/OS Service has been successfully installed!
See https://github.com/mesosphere/marathon-lb for documentation.
[dcosadmin@dcotest01 ceph]$ default_if=$(ip route list | awk '/^default/ {print $5}')
[dcosadmin@dcotest01 ceph]$ IP_ADDR=$( ifconfig $default_if|grep inet|awk -F ' ' '{print $2}'|sed -n 1p )
[dcosadmin@dcotest01 ceph]$ NETMASK=$( ifconfig $default_if|grep inet|awk -F ' ' '{print $4}'|sed -n 1p )
[dcosadmin@dcotest01 ceph]$ IFS=. read -r i1 i2 i3 i4 <<< "$IP_ADDR"
[dcosadmin@dcotest01 ceph]$ IFS=. read -r m1 m2 m3 m4 <<< "$NETMASK"
[dcosadmin@dcotest01 ceph]$ NETWORK=$( printf "%d.%d.%d.%d\n" "$((i1 & m1))" "$((i2 & m2))" "$((i3 & m3))" "$((i4 & m4))" )
[dcosadmin@dcotest01 ceph]$ mask2cdr ()
> {
> local x=${1##*255.}
> set -- 0^^^128^192^224^240^248^252^254^ $(( (${#1} - ${#x})*2 )) ${x%%.*}
> x=${1%%$3*}
> echo $(( $2 + (${#x}/4) ))
> }
[dcosadmin@dcotest01 ceph]$ CDRMASK=$(mask2cdr $NETMASK)
[dcosadmin@dcotest01 ceph]$ HOST_NETWORK=$NETWORK"/"$CDRMASK
[dcosadmin@dcotest01 ceph]$ echo $HOST_NETWORK
172.16.110.0/23
[dcosadmin@dcotest01 ceph]$ MESOS_ROLE="ceph-role"
[dcosadmin@dcotest01 ceph]$ MESOS_PRINCIPAL="ceph-principal"
[dcosadmin@dcotest01 ceph]$ MESOS_SECRET=""
[dcosadmin@dcotest01 ceph]$ PUBLIC_NETWORK=$HOST_NETWORK
[dcosadmin@dcotest01 ceph]$ CLUSTER_NETWORK=$HOST_NETWORK
[dcosadmin@dcotest01 ceph]$ ZOOKEEPER="leader.mesos:2181"
[dcosadmin@dcotest01 ceph]$ API_HOST="0.0.0.0"
[dcosadmin@dcotest01 ceph]$ MESOS_MASTER="leader.mesos:5050"
[dcosadmin@dcotest01 ceph]$ DOWNLOAD_URI="https://dl.bintray.com/vivint-smarthome/ceph-on-mesos/ceph-on-mesos-0.2.9.tgz"
[dcosadmin@dcotest01 ceph]$
[dcosadmin@dcotest01 ceph]$ rm -f ./ceph-dcos.json
[dcosadmin@dcotest01 ceph]$ sudo cat >> ceph-dcos.json << 'EOF'
> {
>   "id": "/ceph",
>   "cmd": "cd /mnt/mesos/sandbox/ceph-on-mesos-*\nbin/ceph-on-mesos --api-port=$PORT0",
> EOF
[dcosadmin@dcotest01 ceph]$ sudo cat >> ceph-dcos.json << EOF
>   "cpus": 0.3,
>   "mem": 512,
>   "disk": 0,
>   "instances": 1,
>   "env": {
>     "MESOS_ROLE": "$MESOS_ROLE",
>     "MESOS_PRINCIPAL": "$MESOS_PRINCIPAL",
>     "PUBLIC_NETWORK": "$PUBLIC_NETWORK",
>     "CLUSTER_NETWORK": "$CLUSTER_NETWORK",
>     "ZOOKEEPER": "$ZOOKEEPER",
>     "API_HOST": "$API_HOST",
>     "MESOS_MASTER": "$MESOS_MASTER"
>   },
>   "uris": ["$DOWNLOAD_URI"],
>   "container": {
>     "type": "DOCKER",
>     "docker": {
>       "image": "mesosphere/marathon:v1.3.3",
>       "forcePullImage": false,
>       "privileged": false,
>       "network": "HOST"
>     },
>     "volumes": [
>       {
>         "containerPath": "/dev/random",
>         "hostPath": "/dev/urandom",
>         "mode": "RO"
>       }
>     ]
>   },
>   "healthChecks": [
>     {
>       "protocol": "TCP",
>       "gracePeriodSeconds": 300,
>       "intervalSeconds": 60,
>       "timeoutSeconds": 20,
>       "maxConsecutiveFailures": 3
>     }
>   ],
>   "upgradeStrategy": {
>     "minimumHealthCapacity": 0,
>     "maximumOverCapacity": 0
>   },
>   "labels": {
>     "MARATHON_SINGLE_INSTANCE_APP": "true",
>     "HAPROXY_GROUP": "external",
>     "DCOS_SERVICE_NAME": "ceph",
>     "DCOS_SERVICE_SCHEME": "http",
>     "DCOS_SERVICE_PORT_INDEX": "0",
>     "DCOS_PACKAGE_IS_FRAMEWORK": "false"
>   },
>   "acceptedResourceRoles": [
>     "*",
>     "slave_public"
>   ],
>   "portDefinitions": [
>     {
>       "protocol": "tcp",
>       "port": 5000,
>       "servicePort": 5000,
>       "labels": {
>         "VIP_0": "/ceph:5000"
>       },
>       "name": "api"
>     }
>   ]
> }
> EOF
[dcosadmin@dcotest01 ceph]$
[dcosadmin@dcotest01 ceph]$ dcos marathon app add ./ceph-dcos.json
Created deployment 11bf2bc6-1714-448d-9133-ee2a6cddccbc
[dcosadmin@dcotest01 ceph]$
Screenshot after completing installation of marathon-lb and ceph

Marathon-lb and Ceph Screenshot

Ceph configuration web interface

Ceph web interface

Configure Ceph

Go to the public agent ip address with port number 5000 if the ceph is installed using the above method

Update mon setting to follow

Ceph Monitor Setting

Click "Save Changes" and click "Home"

"Home" screenshot after running monitor process properly

Ceph Monitor Result

To check whether Ceph Mon service is running, use telnet to private agent with port 6789

[dcosadmin@dcotest01 ceph]$ telnet 172.16.110.31 6789
Trying 172.16.110.31...
Connected to 172.16.110.31.
Escape character is '^]'.
ceph v027▒▒n▒▒n^C
exit
Connection closed by foreign host.
[dcosadmin@dcotest01 ceph]$ telnet 172.16.110.32 6789
Trying 172.16.110.32...
Connected to 172.16.110.32.
Escape character is '^]'.
ceph v027▒▒n ▒.▒n^Cexit
Connection closed by foreign host.
[dcosadmin@dcotest01 ceph]$
Update OSDs setting

Ceph OSDs Setting

OSD Result after deploying

Ceph OSDs Result

Ceph configuration file

deployment {
  # # The docker image to use to launch Ceph.
  # docker_image = "ceph/daemon:tag-build-master-jewel-ubuntu-14.04"

  mon {
    count = 3
    cpus = 0.3
    mem = 256.0

    # # The type of multi-disk volume to use; valid values are root, path, and mount.
    disk_type = root

    # # Size of persistent volume. In the case of diskType = mount, the minimum size of disk to allocate.
    disk = 16
  }

  osd {
    # # Number of OSD instances to spawn
    count = 6

    cpus = 0.3

    mem = 512
    # # The type of multi-disk volume to use for the persistent volume; valid values are root, path, and mount.
    disk_type = mount

    # # Size of persistent volume. In the case of diskType = mount, the minimum size of disk to allocate. It is heavily
    # # ill-advised to use anything except mount disks for OSDs.
    disk = 20000

    # # For diskType = mount, don't allocate drives larger than this.

    # disk_max = 1048576

    # # pathConstraint will tell the ceph framework to only allocate persistent mount volumes at a path which FULLY
    # # matches the provided regular expression (I.E. pretend an implicit '^' is added at the beginning of your regex
    # # and a '$' at the end).

    # path_constraint = "/mnt/ssd-.+"
  }

  rgw {
    count = 0
    cpus = 1
    mem = 256

    # # If port is specified then a port resource is not requested, and it is implied that the container is running on a
    # # network where that port is guaranteed to be available
    # port = 80

    # # docker_flags specifies an array of arbitrary launch parameters to specify for the docker container
    docker_args = {
      # network = weave
      # hostname = "cephrgw.weave.local"
    }
  }
}

settings {
  # These settings are transparently inserted into the generated ceph.conf file, where values in the 'auth {}' will be
  # inserted in the corresponding [auth] ceph.conf section.
  auth {
    cephx = true
    cephx_require_signatures = false
    cephx_cluster_require_signatures = true
    cephx_service_require_signatures = false
  }

  global {
    max_open_files = 131072
    osd_pool_default_pg_num = 128
    osd_pool_default_pgp_num = 128
    osd_pool_default_size = 3
    osd_pool_default_min_size = 1

    mon_osd_full_ratio = .95
    mon_osd_nearfull_ratio = .85
  }

  mon {
    mon_osd_down_out_interval = 600
    mon_osd_min_down_reporters = 4
    mon_clock_drift_allowed = .15
    mon_clock_drift_warn_backoff = 30
    mon_osd_report_timeout = 300
  }

  osd {
    osd_journal_size = 100

    osd_mon_heartbeat_interval = 30

    # # crush
    pool_default_crush_rule = 0
    osd_crush_update_on_start = true

    # # backend
    osd_objectstore = filestore

    # # performance tuning
    filestore_merge_threshold = 40
    filestore_split_multiple = 8
    osd_op_threads = 8
    filestore_op_threads = 8
    filestore_max_sync_interval = 5
    osd_max_scrubs = 1

    # # recovery tuning
    osd_recovery_max_active = 5
    osd_max_backfills = 2
    osd_recovery_op_priority = 2
    osd_client_op_priority = 63
    osd_recovery_max_chunk = 1048576
    osd_recovery_threads = 1
  }

  client {
    rbd_cache_enabled = true
    rbd_cache_writethrough_until_flush = true
  }

  mds {
    mds_cache_size = 100000
  }
}
Configure Ceph Clients

Zookeeper UI address is http://$DOCS_Master_IP:8181. In my case, http://172.16.110.30:8181. For detail refer section "Ceph clients: Find out and export Ceph secrets" from

Ceph example from DCOS 1.9

ZooKeeper

Go to the master node which is 172.16.110.30 and install Ceph Client. The reason I choose to install Master node instead of Bootstrap is because Bootstrap node can't access marathon lb and mesos dns.

sudo su -

wget http://stedolan.github.io/jq/download/linux64/jq chmod +x ./jq cp jq /usr/bin

echo $HOST_NETWORK export HOST_NETWORK=172.16.110.0/23 #change to your specific output

export SECRETS='{"fsid":"a42e63e3-c613-4a1d-9056-ab6d364f4fa5","adminRing":"AQA/7UdZI4R7ZhAA12BPLoX0fvAKmsJbaGgY4g==","monRing":"AQA/7UdZcOb+ZhAAXTZagxDQPk7L60z+DLOalg==","mdsRing":"AQA/7UdZ+sD/ZhAAeriXkkd55o1A/DJOSTwe7w==","osdRing":"AQA/7UdZ0DgAZxAAFOmd+bApr6wMsHfGSx/9gw==","rgwRing":"AQA/7UdZA9IAZxAATDOTLEDtVdQ3WT6+tOBgig=="}{"fsid":"a42e63e3-c613-4a1d-9056-ab6d364f4fa5","adminRing":"AQA/7UdZI4R7ZhAA12BPLoX0fvAKmsJbaGgY4g==","monRing":"AQA/7UdZcOb+ZhAAXTZagxDQPk7L60z+DLOalg==","mdsRing":"AQA/7UdZ+sD/ZhAAeriXkkd55o1A/DJOSTwe7w==","osdRing":"AQA/7UdZ0DgAZxAAFOmd+bApr6wMsHfGSx/9gw==","rgwRing":"AQA/7UdZA9IAZxAATDOTLEDtVdQ3WT6+tOBgig=="}' echo "$SECRETS" |jq .fsid mkdir -p /etc/ceph export HOST_NETWORK=172.16.110.0/23 #Use the value for the network where your DC/OS nodes live. rpm --rebuilddb && yum install -y bind-utils export MONITORS=$(for i in $(dig srv _mon._tcp.ceph.mesos|awk '/^_mon._tcp.ceph.mesos/'|awk '{print $8":"$7}'); do echo -n $i',';done) cat <<-EOF > /etc/ceph/ceph.conf [global] fsid = $(echo "$SECRETS" | jq .fsid) mon host = "${MONITORS::-1}" auth cluster required = cephx auth service required = cephx auth client required = cephx public network = $HOST_NETWORK cluster network = $HOST_NETWORK max_open_files = 131072 mon_osd_full_ratio = ".95" mon_osd_nearfull_ratio = ".85" osd_pool_default_min_size = 1 osd_pool_default_pg_num = 128 osd_pool_default_pgp_num = 128 osd_pool_default_size = 3 rbd_default_features = 1 EOF

cat <<-EOF > /etc/ceph/ceph.mon.keyring [mon.] key = $(echo "$SECRETS" | jq .monRing -r) caps mon = "allow *" EOF

cat <<-EOF > /etc/ceph/ceph.client.admin.keyring [client.admin] key = $(echo "$SECRETS" | jq .adminRing -r) auid = 0 caps mds = "allow" caps mon = "allow *" caps osd = "allow *" EOF

rpm --rebuilddb #sometimes the dB needs this after install yum install -y centos-release-ceph-jewel yum install -y ceph

Output of command

[root@dcotest03 ~]#
[root@dcotest03 ~]# wget http://stedolan.github.io/jq/download/linux64/jq
--2017-06-08 13:47:07--  http://stedolan.github.io/jq/download/linux64/jq
Resolving stedolan.github.io (stedolan.github.io)... 151.101.148.133
Connecting to stedolan.github.io (stedolan.github.io)|151.101.148.133|:80... connected.
HTTP request sent, awaiting response... 200 OK
Length: 497799 (486K) [application/octet-stream]
Saving to: ‘jq’

100%[==========================================================>] 497,799     1.69MB/s   in 0.3s

2017-06-08 13:47:08 (1.69 MB/s) - ‘jq’ saved [497799/497799]

[root@dcotest03 ~]# chmod +x ./jq
[root@dcotest03 ~]# cp jq /usr/bin
[root@dcotest03 ~]#
[root@dcotest03 ~]# echo $HOST_NETWORK

[root@dcotest03 ~]# export HOST_NETWORK=172.16.110.0/23  #change to your specific output
[root@dcotest03 ~]#
[root@dcotest03 ~]# export SECRETS='{"fsid":"139865ff-572b-4c09-9856-5b029b5dba01","adminRing":"AQBTjzlZGptSTxAAZcjiBrOqYL8NopbKpzko1A==","monRing":"AQBTjzlZXGMWURAAwdqIbG4xph3nwWJ+uxPFUQ==","mdsRing":"AQBTjzlZ3xsXURAAlqZ587t6Wnz/i9h/fJaUpg==","osdRing":"AQBTjzlZsM8XURAA0//Ej7UPBmU0IRcf5JZJOw==","rgwRing":"AQBTjzlZhYAYURAA90BOSx9UQgvEjYI5wD+YHQ=="}'
[root@dcotest03 ~]# echo "$SECRETS" |jq .fsid
"139865ff-572b-4c09-9856-5b029b5dba01"
[root@dcotest03 ~]#
[root@dcotest03 ~]# mkdir -p /etc/ceph
[root@dcotest03 ~]# export HOST_NETWORK=172.31.0.0/20       #Use the value for the network where your DC/OS nodes live.
[root@dcotest03 ~]# rpm --rebuilddb && yum install -y bind-utils
Loaded plugins: fastestmirror
base                                                                         | 3.6 kB  00:00:00
dockerrepo                                                                   | 2.9 kB  00:00:00
extras                                                                       | 3.4 kB  00:00:00
updates                                                                      | 3.4 kB  00:00:00
Loading mirror speeds from cached hostfile
 * base: ca.mirror.babylon.network
 * extras: ca.mirror.babylon.network
 * updates: ca.mirror.babylon.network
Package 32:bind-utils-9.9.4-38.el7_3.3.x86_64 already installed and latest version
Nothing to do
[root@dcotest03 ~]# export MONITORS=$(for i in $(dig srv _mon._tcp.ceph.mesos|awk '/^_mon._tcp.ceph.mesos/'|awk '{print $8":"$7}'); do echo -n $i',';done)
[root@dcotest03 ~]# cat <<-EOF > /etc/ceph/ceph.conf
> [global]
> fsid = $(echo "$SECRETS" | jq .fsid)
> mon host = "${MONITORS::-1}"
> auth cluster required = cephx
> auth service required = cephx
> auth client required = cephx
> public network = $HOST_NETWORK
> cluster network = $HOST_NETWORK
> max_open_files = 131072
> mon_osd_full_ratio = ".95"
> mon_osd_nearfull_ratio = ".85"
> osd_pool_default_min_size = 1
> osd_pool_default_pg_num = 128
> osd_pool_default_pgp_num = 128
> osd_pool_default_size = 3
> rbd_default_features = 1
> EOF
[root@dcotest03 ~]#
[root@dcotest03 ~]# cat <<-EOF > /etc/ceph/ceph.mon.keyring
> [mon.]
>  key = $(echo "$SECRETS" | jq .monRing -r)
>  caps mon = "allow *"
> EOF
[root@dcotest03 ~]#
[root@dcotest03 ~]# cat <<-EOF > /etc/ceph/ceph.client.admin.keyring
> [client.admin]
>   key = $(echo "$SECRETS" | jq .adminRing -r)
>   auid = 0
>   caps mds = "allow"
>   caps mon = "allow *"
>   caps osd = "allow *"
> EOF
[root@dcotest03 ~]#
[root@dcotest03 ~]# rpm --rebuilddb  #sometimes the dB needs this after install
[root@dcotest03 ~]# yum install -y centos-release-ceph-jewel
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: ca.mirror.babylon.network
 * extras: ca.mirror.babylon.network
 * updates: ca.mirror.babylon.network

skip all messages for new packages ....

Complete!
[root@dcotest03 ~]#

Create Share Disk

VOLUME_NAME="test" VOLUME_MOUNT_PATH="/mnt/ceph" rbd create --size=1G $VOLUME_NAME VOLUME_DEV=$( rbd map $VOLUME_NAME ) #Expected output: "/dev/rbd0" mkfs.xfs -f $VOLUME_DEV mkdir -p $VOLUME_MOUNT_PATH mount $VOLUME_DEV $VOLUME_MOUNT_PATH

cd $VOLUME_MOUNT_PATH touch "DOES_THIS_WORK_-_RIGHT_ON" ls

[dcosadmin@dcotest04 ~]$ sudo /bin/python /bin/ceph mon getmap -o /etc/ceph/monmap-ceph got monmap epoch 8 [dcosadmin@dcotest04 ~]$

As an additional test, check the status of the Ceph cluster: /bin/python /bin/ceph -s

Testing

Then use these commands to create a RBD volume using Ceph, format it and mount it under the PATH defined in the variable above:

sudo su - VOLUME_NAME="dcos" VOLUME_MOUNT_PATH="/mnt/ceph/dcos" VOLUME_SIZE="20G" rbd create --size=$VOLUME_SIZE $VOLUME_NAME VOLUME_DEV=$( rbd map $VOLUME_NAME ) echo $VOLUME_DEV #Expected output: "/dev/rbdX" where X is the volume number mkfs.xfs -f $VOLUME_DEV mkdir -p $VOLUME_MOUNT_PATH mount $VOLUME_DEV $VOLUME_MOUNT_PATH

[dcosadmin@dcotest03 ~]$ sudo su -
Last login: Thu Jun  8 16:58:44 MDT 2017 from 172.16.110.20 on pts/0
[root@dcotest03 ~]# VOLUME_NAME="dcos"
[root@dcotest03 ~]# VOLUME_MOUNT_PATH="/mnt/ceph/dcos"
[root@dcotest03 ~]# VOLUME_SIZE="20G"
[root@dcotest03 ~]# rbd create --size=$VOLUME_SIZE $VOLUME_NAME
mkfs.xfs -f $VOLUME_DEV
mkdir -p $VOLUME_MOUNT_PATH
mount $VOLUME_DEV $VOLUME_MOUNT_PATH
rbd: create error: (17) File exists
2017-06-09 12:05:06.407754 7f04add6ad80 -1 librbd: rbd image dcos already exists
[root@dcotest03 ~]# VOLUME_DEV=$( rbd map $VOLUME_NAME )
[root@dcotest03 ~]# echo $VOLUME_DEV
/dev/rbd1
[root@dcotest03 ~]# #Expected output: "/dev/rbdX" where X is the volume number
[root@dcotest03 ~]# mkfs.xfs -f $VOLUME_DEV
meta-data=/dev/rbd1              isize=512    agcount=17, agsize=326656 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=5242880, imaxpct=25
         =                       sunit=1024   swidth=1024 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=8 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
[root@dcotest03 ~]# mkdir -p $VOLUME_MOUNT_PATH
[root@dcotest03 ~]# mount $VOLUME_DEV $VOLUME_MOUNT_PATH
[root@dcotest03 ~]#
Other way to simply check the stats of CEPH is from docker image. All docker images for Ceph will have ceph command, so without ceph client, you can simply check the ceph status

Go to one of ceph osd or monitor node and run following command

[dcosadmin@dcotest03 ~]$ sudo su -
Last login: Mon Jun 26 12:46:39 MDT 2017 from 172.16.110.20 on pts/0
[root@dcotest03 ~]# docker ps
CONTAINER ID        IMAGE                                             COMMAND                   CREATED             STATUS              PORTS               NAMES
b7221d101129        ceph/daemon:tag-build-master-jewel-ubuntu-14.04   "/bin/sh -c '\necho..."   7 days ago          Up 7 days                               mesos-92e6cfe5-a9c1-4e10-bfe4-5e6779a2de55-S12.36ae42fc-1eed-4c55-a293-a88f4551e832
173dec782656        ceph/daemon:tag-build-master-jewel-ubuntu-14.04   "/bin/sh -c '\necho..."   7 days ago          Up 7 days                               mesos-92e6cfe5-a9c1-4e10-bfe4-5e6779a2de55-S12.9365eae2-be92-489e-8477-098654eca719
[root@dcotest03 ~]# docker exec -it 173dec782656 ceph -s
    cluster a42e63e3-c613-4a1d-9056-ab6d364f4fa5
     health HEALTH_OK
     monmap e3: 3 mons at {172.16.110.31=172.16.110.31:6789/0,172.16.110.33=172.16.110.33:6789/0,172.16.110.35=172.16.110.35:6789/0}
            election epoch 6, quorum 0,1,2 172.16.110.31,172.16.110.33,172.16.110.35
     osdmap e24: 6 osds: 6 up, 6 in
            flags sortbitwise,require_jewel_osds
      pgmap v2166: 64 pgs, 1 pools, 306 bytes data, 4 objects
            800 MB used, 119 GB / 119 GB avail
                  64 active+clean
[root@dcotest03 ~]# docker exec -it 173dec782656 ceph health
HEALTH_OK
[root@dcotest03 ~]#
Troubleshoting

ceph -s returns pipe error

Use telnet and check whether port is working properly. In my case, somehow the Ceph configuration UI shows that 1025 port is used, but somehow some of nodes are using 6789.

[dcosadmin@dcotest01 ceph]$ telnet 172.16.110.32 1025 Trying 172.16.110.32... telnet: connect to address 172.16.110.32: Connection refused [dcosadmin@dcotest01 ceph]$ telnet 172.16.110.33 1025 Trying 172.16.110.33... Connected to 172.16.110.33. Escape character is '^]'. ceph v027▒n!▒▒nexot ^CConnection closed by foreign host. [dcosadmin@dcotest01 ceph]$ [dcosadmin@dcotest01 ceph]$ telnet 172.16.110.31 1025 Trying 172.16.110.31... telnet: connect to address 172.16.110.31: Connection refused [dcosadmin@dcotest01 ceph]$ telnet 172.16.110.34 1025 Trying 172.16.110.34... Connected to 172.16.110.34. Escape character is '^]'. ceph v027▒n"▒x▒nexit ^CConnection closed by foreign host. [dcosadmin@dcotest01 ceph]$ telnet 172.16.110.35 1025 Trying 172.16.110.35... Connected to 172.16.110.35. Escape character is '^]'. ceph v027▒n#▒▒nexit ^CConnection closed by foreign host. [dcosadmin@dcotest01 ceph]$ [dcosadmin@dcotest01 ceph]$ [dcosadmin@dcotest01 ceph]$ [dcosadmin@dcotest01 ceph]$ ssh 172.16.110.31 Last login: Thu Jun 8 17:48:54 2017 from 172.16.110.20 [dcosadmin@dcotest03 ~]$ sudo vi /etc/ceph/ceph.conf [dcosadmin@dcotest03 ~]$ sudo ceph -s cluster 139865ff-572b-4c09-9856-5b029b5dba01 health HEALTH_OK monmap e4: 3 mons at {172.16.110.31=172.16.110.31:6789/0,172.16.110.32=172.16.110.32:6789/0,172.16.110.35=172.16.110.35:1025/0} election epoch 8, quorum 0,1,2 172.16.110.35,172.16.110.31,172.16.110.32 osdmap e20: 6 osds: 4 up, 4 in flags sortbitwise,require_jewel_osds pgmap v38: 64 pgs, 1 pools, 0 bytes data, 0 objects 532 MB used, 99418 MB / 99951 MB avail 64 active+clean [dcosadmin@dcotest03 ~]$

Install Ceph Dashboard

To install Ceph Dashboard, ceph.conf and admin key ring file will be needed to provide through http service. For this, lighttpd is installed on the bootstraip node which is 172.16.110.20.

Install lighttpd sudo su - yum install epel-release yum update yum install lighttpd service lighttpd start chkconfig lighttpd on cp /etc/ceph/* /var/www/lighttpd/

Address for the Ceph dashboard http://public_node:15000. For me, http://172.16.110.37:15000

Ceph Dashboard

Useful Command for Ceph

rbd showmapped
df -hT
ceph -w : watch window showing real time progress
ceph osd pool create replicatedpool0 200 200 replicated : create replicated pool
Summary

Next step will be using CEPH storage during DC/OS package installation.

SHARE
Labels

centos
ceph
DCOS
Docker
shared storage
LABELS: CENTOS CEPH DCOS DOCKER SHARED STORAGE
SHARE
Comments




Popular posts from this blog

Using GIT(Bitbucket), Visual Studio Code
February 22, 2016
Concept of Git Git has two repositories; local and remote. Two different commands type to commit the changes; 1. commit/add: load/save changes to the local repository. 2. push/pull/clone: load/save changes from/to remote repository.
How to setup remote git server , bitbucket, with Visual Studio Code To use git, I downloaded it from [git-scm](“https://git-scm.com/downloads“) and installed with bash mode to keep the comparability for different platform.
Set up remote repository *
Create project from bitbucket. In this case, I created “blogmarkdown”.Remember the URL for the git repository. To find out the repository, just add “.git” at the end of the URL from bitbucket. For me, it will be “https://alexjoh@bitbucket.org/alexjoh/blogmarkdown.git”Link the remote with local folder *

Create local folder. In my case, I created d:\gitrepoInitialize git local repo. Change the folder to the gitrepo and run git initIf there are existing files from a remote git repository, adding remote site. Run g…
SHARE
 POST A COMMENT
READ MORE

Sample application for Active Directory SSO with Spring Security 4 and Waffle
June 08, 2015
IntroductionI've developed quotation program with Mybatis, Spring MVC, and SQL Server, but I had a request of integrating this module with Spring Security and Active Directory. I've researched about possible solutions and I've spent quite bit of time with Waffle and SAML. SAML is more ideal, but I found out that the entire implementation is too complicated and I decided to use Waffle for this purpose. One of drawback of Waffle is that the Tomcat server must be runned from Windows platform.
I tried to find out spring security example with Waffle, but it is hard to find out the sample from Internet. It took so many hours to create this simple example.
Tools Spring STS: 3.6.4 Spring Security : 4.0.1 Spring framework: 4.x.x Waffle: 1.7.4
Implementation Creating Spring MVC Project Create New Project -> Spring Project -> Spring MVC Updating POM To make easy of managing version, added two versions under "properties"
<properties> <java-version>1.6</java-version&g…
SHARE
 4 COMMENTS
READ MORE
Installing Icinga 2.4.1, Graylog 1.2.2, and Cacti 0.8.8 on Ubuntu 14.04
December 08, 2015
Installing Icinga 2.4.1, Graylog 1.2.2, and Cacti 0.8.8 Date: Dec 7, 2015
Overview Before investing to commercial monitoring software, I decided to use open source product and final choice is Icinga for monitoring, Graylog for log collection, and Cacti for graph. The MySQL is the choice because of the Cacti. The Cacti doesn’t support the Postgresql.
Version
- Ubuntu: 14.04
- Icinga: 2.4.1
- Icinga Web: 2.1.0
- Graylog Server: 1.2.2
- Graylog web: 1.2.2
- Java: 7.x
- MongoDB: 2.6.11
- ElasticSearch: 1.7
- Cacti: 0.8.8 Useful command Checking contents in the package Using dpkg alex@monitoring:~$ sudo dpkg -l icinga2
Desired=Unknown/Install/Remove/Purge/Hold
| Status=Not/Inst/Conf-files/Unpacked/halF-conf/Half-inst/trig-aWait/Trig-pend
|/ Err?=(none)/Reinst-required (Status,Err: uppercase=bad)
||/ Name Version Architecture Description
+++-==============-============-============-=================================
ii icinga2 2.4.1-1~…
SHARE
 POST A COMMENT
READ MORE

About Me

Alex Joh
VISIT PROFILE
Archive
Labels
Report Abuse
 Powered by Blogger
ALEX JOH'S BLOG

SEARCH
