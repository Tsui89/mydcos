
<span id="qa">QA</span>
=================

* [Table of Contents](#qa)
   * [PaaS中网络模式Host、Bridge、Virtual Network的区别？](#PaaS中网络模式Host、Bridge、Virtual Network的区别)
   * [PaaS中存储类型的区别？](#PaaS中存储类型的区别)
   * [PaaS中的应用命名](#PaaS中的应用命名)
   * [PaaS中的服务发现](#PaaS中的服务发现)


注：
* node节点是指PaaS中真正运行容器的主机。
* 有状态应用是指有存储资源的应用。
* 无状态应用是指没存储资源，也没有指定运行node节点的应用。

<span id='PaaS中网络模式Host、Bridge、Virtual Network的区别'>PaaS中网络模式Host、Bridge、Virtual Network的区别</span>
------

| 模式 | 类似于docker网络中 | 跨node节点容器之间通信 | 跨node节点容器与任意节点之间通信
| --- | --- | --- | --- |
| Host | Host | 可以 | 可以 |
| Bridge | Bridge | 不可以 | 不可以 |
| Virtual Network | Overlay | 可以 | 可以 |

<span id="PaaS中存储类型的区别">PaaS中存储类型的区别</span>
------

| 模式 | 资源类型 | 删除应用 | 重启应用 | 使用方法 |
| --- | --- | --- | --- | --- |
| Host Volume | 本地路径 | 数据保留 | 数据保留 | 先在目标node节点上创建路径，然后运行容器时指定运行node节点。
| Persistent Volume | 存储资源池 | 数据销毁 | 数据保留 | 先在存储资源池中创建存储资源，然后将存储资源挂载到容器的指定路径。

* 有状态应用无论使用哪种存储模式，都是不可以自动迁移的。使用Persistent Volume时，PaaS会找一个满足资源需求的node节点创建存储资源，之后这个应用只运行在这个node节点。
* 只要应用不删除，存储的数据就不会销毁。
* Host Volume挂载的目录文件，在PaaS应用界面的Files标签页不可见。

<span id="PaaS中的应用命名">PaaS中的应用命名</span>
------

运维团队的工作区是ops,创建了一个应用叫test,那这个应用在PaaS中的Service ID命名是/ops/test。
因为用户是看不到非本工作区应用的，所以在创建应用的时候，一定要看一看Service ID那一栏有没有自己工作区的前缀。

<span id="PaaS中的服务发现">PaaS中的服务发现</span>
------

PaaS中部署的应用都已经加入了内网dns解析，按域名命名规则访问就可以，命名规则示例,比如应用/ops/test

* test.ops.marathon.mesos，dns解析到的是容器IP
* test.ops.marathon.slave.mesos，dns解析到的是容器所在的node节点IP


[Hit Top](#qa)
