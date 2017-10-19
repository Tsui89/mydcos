#!/usr/bin/env bash

#on glusterfs node
yum install -y centos-release-gluster
yum --enablerepo=centos-gluster*-test install -y glusterfs-server
systemctl enable glusterd

mkfs.xfs -i size=512 /dev/sdc
mkdir -p /glusterfs/data/brick1
echo '/dev/sdc /glusterfs/data/brick1 xfs defaults 1 2' >> /etc/fstab
mount -a && mount

#/etc/hosts
192.168.131.1   server1
192.168.131.2   server2

#on server1
gluster peer probe server2

gluster volume create gv0 replica 2 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 force


#on dcos node /etc/rc.local
mount -t glusterfs server1:/gv0 /dcos/gfs0


#echo 'server1:/gv0	/dcos/gfs0	glusterfs	defaults 1 2' >> /etc/fstab
#mount -a && mount


#192.168.131.1   server1
#192.168.131.2   server2
#192.168.131.3   server3
#192.168.131.4   server4
#
#yum -y install glusterfs glusterfs-fuse
#vi /var/lib/glusterd/peers/12598d79-2d93-4489-b049-66d9bc5069ad
#
#gluster volume create gv0 replica 4 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 server3:/glusterfs/data/brick1 server4:/dcos/path0/data/brick1 force
#
#
#
#Brick1: server1:/glusterfs/data/brick1
#Brick2: server2:/glusterfs/data/brick1
#Brick3: server3:/glusterfs/data/brick1
#Brick4: server4:/dcos/path0/data/brick1
#
#gluster volume start gv0
#
#mkdir /dcos/gfs0
#mount -t glusterfs server1:/gv0 /dcos/gfs0
#
#gluster volume stop gv0
#gluster volume remove-brick gv0 replica 2 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 start
#
#
#
#[root@dcos-cloud1 /]# gluster volume  remove-brick gv0 replica 4 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 start
#volume remove-brick start: failed: given replica count (4) option is more than volume gv0's replica count (2)
#[root@dcos-cloud1 /]# gluster volume  remove-brick gv0 replica 2 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 start
#volume remove-brick start: failed: Removing bricks from replicate configuration is not allowed without reducing replica count explicitly.
#[root@dcos-cloud1 /]# gluster volume  add-brick gv0 replica 2 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 start
#Wrong brick type: start, use <HOSTNAME>:<export-dir-abs-path>
#Usage: volume add-brick <VOLNAME> [<stripe|replica> <COUNT> [arbiter <COUNT>]] <NEW-BRICK> ... [force]
#[root@dcos-cloud1 /]# gluster volume  add-brick gv0 replica 4 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 start
#Wrong brick type: start, use <HOSTNAME>:<export-dir-abs-path>
#Usage: volume add-brick <VOLNAME> [<stripe|replica> <COUNT> [arbiter <COUNT>]] <NEW-BRICK> ... [force]
#[root@dcos-cloud1 /]# gluster volume  add-brick gv0 replica 4 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 force
#volume add-brick: failed:  Volume must not be in stopped state when replica-count needs to  be increased.
#[root@dcos-cloud1 /]# gluster volume start gv0
#volume start: gv0: success
#[root@dcos-cloud1 /]# gluster volume  add-brick gv0 replica 4 server1:/glusterfs/data/brick1 server2:/glusterfs/data/brick1 force
#volume add-brick: success
#[root@dcos-cloud1 /]# gluster peer detach server4
#peer detach: failed: Brick(s) with the peer server4 exist in cluster
#[root@dcos-cloud1 /]# gluster volume  remove-brick gv0 replica 2 server3:/glusterfs/data/brick1 server4:/dcos/path0/data/brick1 start
#volume remove-brick start: failed: Migration of data is not needed when reducing replica count. Use the 'force' option
#[root@dcos-cloud1 /]# gluster volume  remove-brick gv0 replica 2 server3:/glusterfs/data/brick1 server4:/dcos/path0/data/brick1 force
#Removing brick(s) can result in data loss. Do you want to Continue? (y/n) y
#volume remove-brick commit force: success
#[root@dcos-cloud1 /]# gluster volume info
#
#Volume Name: gv0
#Type: Replicate
#Volume ID: 5a0d9712-5b3d-4dd8-a9ae-a01bb8af3354
#Status: Started
#Snapshot Count: 0
#Number of Bricks: 1 x 2 = 2
#Transport-type: tcp
#Bricks:
#Brick1: server1:/glusterfs/data/brick1
#Brick2: server2:/glusterfs/data/brick1
#Options Reconfigured:
#transport.address-family: inet
#nfs.disable: on
#performance.client-io-threads: off


