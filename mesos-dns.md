#### 修改mesos-dns配置，支持获取容器ip/agent-ip


```
[root@master1 ~]# cat /opt/mesosphere/etc/mesos-dns.json
{
  "zk": "zk://zk-1.zk:2181,zk-2.zk:2181,zk-3.zk:2181,zk-4.zk:2181,zk-5.zk:2181/mesos",
  "refreshSeconds": 30,
  "ttl": 60,
  "domain": "mesos",
  "port": 61053,
  "resolvers": ["10.10.90.230"],
  "timeout": 5,
  "listener": "0.0.0.0",
  "email": "root.mesos-dns.mesos",
  "IPSources": ["host", "netinfo"],
  "SetTruncateBit": true
}
```

修改"IPSources": ["netinfo", "host"]
systemctl restart dcos-mesos-dns

```
[root@dcos-cloud3 ~]# nslookup test1.cwc.marathon.mesos
Server:		198.51.100.1
Address:	198.51.100.1#53

Name:	test1.cwc.marathon.mesos
Address: 20.0.1.162

[root@dcos-cloud3 ~]# nslookup test1.cwc.marathon.slave.mesos
Server:		198.51.100.1
Address:	198.51.100.1#53

Name:	test1.cwc.marathon.slave.mesos
Address: 192.168.131.3

[root@dcos-cloud3 ~]# nslookup
> set type=SRV
> _web-1._test1-cwc._tcp.marathon.mesos.
Server:		198.51.100.1
Address:	198.51.100.1#53

_web-1._test1-cwc._tcp.marathon.mesos	service = 0 0 80 test1-cwc-5tk4d-s7.marathon.mesos.
> exit
```
