rm -rf /tmp/dcos
mkdir /tmp/dcos && cd /tmp/dcos
curl -O http://192.168.131.10:9000/dcos_install.sh
bash dcos_install.sh master
