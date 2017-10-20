# mydcos

## DC/OS 部署

ssh bootstrap:

1. cd bootstrap
2. curl -O https://downloads.dcos.io/dcos/stable/dcos_generate_config.sh
3. bash init.sh
4. reboot
5. vi genconf/config.yaml 修改以下几项
  * agent_list
  * bootstrap_url: 当前主机ip:9000
  * master_list
6. vi genconf/ip-detect
  * MASTER_IP 指向一个所有节点都可访问到的ip
7. bash start.sh

ssh master:

1. cd master-scripts
2. bash init.sh
3. reboot
4. vi deploy.sh 修改dcos_install.sh获取地址
  * curl -O \<bootstrap_url>/dcos_install.sh
5. ./deploy.sh


ssh agent:

1. cd agent-scripts
2. bash init.sh
3. reboot
4. vi deploy.sh 修改dcos_install.sh获取地址
  * curl -O \<bootstrap_url>/dcos_install.sh
5. ./deploy.sh
6. 增加disk资源，查看init-disk.sh，根据实际情况进行修改运行.
  * path类型资源mount规则是 /dcos/path\<number>
  * mount类型资源mount规则是/dcos/volume\<number>
7. 重启dcos-mesos-slave
  * cp utils/make_disk_resources.py /opt/mesosphere/bin/make_disk_resources.py
  * rm -f /var/lib/dcos/mesos-resources
  * rm -f /var/lib/mesos/slave/meta/slaves/latest
  * systemctl restart dcos-mesos-slave



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

查看node resource资源信息

1. 给role(slave_public)预留资源的node resource

    dcos node --json | jq --raw-output '.[] | select(.reserved_resources.slave_public != null)'