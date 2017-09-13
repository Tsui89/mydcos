# mydcos

bootstrap:
1. curl -O https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh
2. yum install docker
3. systemctl stop firewalld && systemctl disable firewalld
4. vi /etc/selinux/config
5. scp  -r bootstrap && cd bootstrap && vi genconf/config.yaml
5. bash dcos_generate_config.sh --genconf
6. docker pull nginx
7. docker run -d -p 9000:80 -v $PWD/genconf/serve:/usr/share/nginx/html:ro nginx


master:

1. scp -r master-scripts && cd master-scripts && vi deploy.sh
2. bash init.sh
3. vi /etc/selinux/config
4. vi /etc/docker/daemon.json "storage-driver":"overlay"
5. reboot
6. ./deploy.sh


agent:

1. scp -r agent-scripts && cd agent-scripts && vi deploy.sh
2. bash init.sh
3. vi /etc/selinux/config
4. vi /etc/docker/daemon.json "storage-driver":"overlay"
5. reboot
6. ./deploy.sh


##### yum install net-tools


##### 应用访问

host、label可以在应用的Details里找到

```shell
$ DOCKER_HOST=192.168.131.3:4243 docker  ps -q --filter "label=MESOS_TASK_ID=k2eyes_influxdb.d73cd2fa-982c-11e7-aaa2-36ce7409b167.9"
e69ff56cb81d

# Tsui @ Capitan in ~ [18:05:04] C:1
$ DOCKER_HOST=192.168.131.3:4243 docker exec -ti e69 bash
root@dcos-cloud3:/#
```
