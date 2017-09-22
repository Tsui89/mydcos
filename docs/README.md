
<span id="qa">QA</span>
======

* [Table of Contents](#qa)
   * [什么是ARTIFACT URI](#artifact)
   * [PaaS中网络模式Host、Bridge、Virtual Network的区别](#PaaS中网络模式的区别)
   * [PaaS中存储类型的区别](#PaaS中存储类型的区别)
   * [Host Volume使用](#HostVolume使用)
   * [PaaS中的应用命名](#PaaS中的应用命名)
   * [PaaS中的服务发现](#PaaS中的服务发现)
   * [PaaS中如何使用dev私有镜像库镜像](#PaaS中如何使用dev私有镜像库镜像)


注：
* node节点是指PaaS中真正运行容器的主机。
* 有状态应用是指有存储资源的应用。
* 无状态应用是指没存储资源，也没有指定运行node节点的应用。

<span id="artifact">什么是ARTIFACT URI</span>
------

创建应用时在Service》MORESRTTINGS下面有个ARTIFACT URI的配置项，这个地方填写的是文件的下载地址，文件会在容器启动之前下载到容器内部。
比如填写本说明文档下载地址 http://download.marathon.slave.mesos:31080/DCOS-Manuals.markdown。
如果URI如下类型的压缩包.tar, .tar.gz, .tar.bz2, .tar.xz .gz, .tgz, .tbz2, .txz, .zip，URI下载之后默认会自动解压。

然后这样使用，将这个文件挂载到容器的指定路径文件，比如hostpath=DCOS-Manuals.markdown containerpath=/path/to/dest/DCOS-Manuals.markdown


<span id="PaaS中网络模式的区别">PaaS中网络模式Host、Bridge、Virtual Network的区别</span>
------

| 模式 | 类似于docker网络中 | 跨node节点容器之间通信 | 跨node节点容器与任意节点之间通信 |
|:---:|:---:|:---:|:---:|
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

<span id="HostVolume使用">Host Volume使用</span>
------

| Host Path（源）| Container Path（目标）| 效果 | 备注 |
| --- | --- | --- | --- |
| 已存在的文件 | 1.已存在的文件 <br> 2.已存在的目录 <br> 3.不存在 | 1.覆盖目标文件 <br> 2.报错，应用创建失败 <br> 3.创建所有中间目录（相当于 mkdir -p），然后映射文件 | 所以，映射文件 foo 到指定目录应该为：<br> hostpath=foo containerpath=/path/to/dest/foo <br> 而不能为：<br> hostpath=foo containerpath=/path/to/dest/，即使 dest 目录已经存在 |
| 已存在的目录 | 1.已存在的文件 <br> 2.已存在的目录 <br> 3.不存在 | 1.报错，应用创建失败 <br> 2.覆盖目标目录  <br> 3.创建所有中间目录（相当于mkdir -p），然后 host path 内所有内容映射到 container path 上 | 所以，映射目录到目录没有什么坑，只需要注意 container path 不是一个已经存在的文件就好 |
| 不存在，会被系统默认为目录 |  1.已存在的文件 <br> 2.已存在的目录 <br> 3.不存在 | 1.报错，应用创建失败 <br> 2.自动创建 host path，然后映射目录 <br> 3.自动创建 host path，自动创建container path，然后映射目录 | - |

* Host路径写相对路径，一般配合artifact、Persistent Volume使用。
* Host路径写绝对路径，绝对路径指的是应用所在的node节点的本地路径。指定运行主机的应用可以使用。

<span id="PaaS中的应用命名">PaaS中的应用命名</span>
------

PaaS中的应用命名（Service ID）是由Group名+应用名组成的。
比如运维团队的工作区Group名是ops,创建了一个应用叫test,那这个应用在PaaS中的Service ID命名是/ops/test。
因为用户是看不到非本工作区应用的，所以在创建应用的时候，一定要看一看Service ID那一栏有没有自己工作区的前缀。

<span id="PaaS中的服务发现">PaaS中的服务发现</span>
------

PaaS中部署的应用都已经加入了内网dns解析，按域名命名规则访问就可以，命名规则示例,比如应用/ops/test

* test.ops.marathon.mesos，dns解析到的是容器IP
* test.ops.marathon.slave.mesos，dns解析到的是容器所在的node节点IP

<span id="PaaS中如何使用dev私有镜像库镜像">PaaS中如何使用dev私有镜像库镜像</span>
------

在PaaS中，使用私有镜像库镜像，在部署应用时需要设置artifact,才能通过registry认证。设置地址在Service》MORESRTTINGS》ARTIFACT URI处填写 file:///etc/docker.tar.gz


[Hit Top](#qa)
