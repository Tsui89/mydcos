资源需求：
* cpu
* memory
* mount disk resource

install ceph client
* export SECRETS
* export PORT_MON=$(dig srv _mon._tcp.ceph.mesos|awk '/^_mon._tcp.ceph.mesos/'|head -n 1|awk '{print $7}')
* ceph.conf  mon host = mon.ceph.mesos:$PORT_MON(真实的值)
* ceph.client.admin.keyring key = ("$SECRETS" | jq .adminRing -r) (真实的值)





[blog](http://alexjoh.blogspot.com/2017/06/install-ceph-shared-storage-to-dcos-19.html)
