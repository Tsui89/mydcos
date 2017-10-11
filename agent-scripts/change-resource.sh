cp ../utils/make_disk_resources.py /opt/mesosphere/bin/make_disk_resources.py

rm -f /var/lib/dcos/mesos-resources
rm -f /var/lib/mesos/slave/meta/slaves/latest
systemctl restart dcos-mesos-slave
