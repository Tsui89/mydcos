rm -rf /var/lib/dcos/
rm -rf /var/lib/mesos
rm -rf /opt/mesosphere/
rm -rf /etc/systemd/system/dcos*
systemctl daemon-reload
ps -ef |grep mesos |grep -v 'grep'|awk -F ' ' '{print $2}' | xargs kill -9
ps -ef |grep dcos |grep -v 'grep'|awk -F ' ' '{print $2}' | xargs kill -9
rm -rf /run/dcos/
