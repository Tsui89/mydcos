#!/usr/bin/env python

import os
import sys
import time
import json
# import urllib2
import urllib
import random
import subprocess
import docker
import logging
import signal


# type appS struct{
# 	Id 		string	`json:"id"`
# 	AppId string	`json:"appId"`
# 	Host 	string	`json:"host"`
# 	State string	`json:"state"`
# }
#
# type taskResponse struct{
# 	TaskR	[]appS	`json:"tasks"`
# }

OS_ERROR_CODE = 0xff
Master_Mesos = ["192.168.131.11","192.168.131.12","192.168.131.13"]

class AppS(object):

    def __init__(self, id, appId, host, state, startedAt,**kwargs):
        self.Id = id
        self.AppId = appId
        self.Host = host
        self.State = state
        self.StartedAt = startedAt

class TaskR(object):

    def __init__(self, tasks):
        self.tasks = tasks

    def getAppS(self):
        for t in self.tasks:
            yield AppS(**t)

def parseApp(app_path=''):

    if not app_path :
        return False
    elif "." in app_path:
        strs = app_path.split('.')
        strs.reverse()
        return "/".join(strs)
    else:
        return app_path

def update(name):
    url_path = "macos/bash-appM" \
        if name == 'bash-appM' \
        else "ubuntu/bash-appU"
    tmp_path = os.path.join("/tmp",name)
    cmd = "wget http://download.marathon.slave.mesos:31080/utils/%s  -O %s" % (url_path,tmp_path)
    subprocess.call(cmd,shell=True)

    cmd = "chmod +x %s" % (tmp_path)
    subprocess.call(cmd,shell=True)
    pid = os.fork()
    if pid == 0:
        os.rename(tmp_path,"/usr/local/bin/%s"%name)
        print name, "update ok."
    else:
        return

def main():
    if len(sys.argv) < 2:
        print "need app path, Usage: %s path-to-app"%sys.argv[0]
        print "\t Or Usage: %s --update to upgrade."
        sys.exit(-1)

    if sys.argv[1] == "--update":
        update(os.path.basename(sys.argv[0]))
        sys.exit(0)

    app_path = parseApp(sys.argv[1])

    print "App: ", app_path


    master = Master_Mesos[random.randint(0, 2)]

    app_url = "http://" + "/".join([master,"marathon","v2/apps", app_path,"tasks"])
    resp = urllib.urlopen(app_url)

    if resp.code != 200:
        print "Get App tasks error.",resp.read()
        sys.exit(-1)
    data = json.loads(resp.read())
    ts = TaskR(**data)


    if len(ts.tasks) == 0:
        print "\t no container running."

    for apps in ts.getAppS():
        client = docker.DockerClient(base_url=apps.Host+":4243",version="1.24",timeout=10)
        containers_id = client.containers.list(filters={"label":"MESOS_TASK_ID=%s"%apps.Id})


        for id in containers_id:
            print "\tHost:      ", apps.Host
            print "\tState:     ",apps.State
            print "\tStartedAt: ",apps.StartedAt
            print "\tLabel:      label=MESOS_TASK_ID=%s"%apps.Id

            cmd = "docker exec -ti %s bash"%(id.id)
            if subprocesscmd(cmd, env={'DOCKER_HOST': apps.Host+":4243"}) < 0 :
                #use sh
                cmd = 'docker exec -ti %s sh' % (id.id)
                subprocesscmd(cmd, env={'DOCKER_HOST': apps.Host+":4243"})


def subprocesscmd(cmd_str='', timeout=None, description='', env=os.environ,
                  show_message=True):

    os_env = os.environ
    env = os_env.update(env)
    poll_time = 0.2
    _time_begin = time.time()
    if show_message:
        stdout = None
        stderr = None
    else:
        stdout = subprocess.PIPE
        stderr = subprocess.PIPE
    try:
        ret = subprocess.Popen(cmd_str, stdout=stdout, stderr=stderr,
                               shell=True, env=env)
    except OSError as e:
        logging.error('%s %s %s %s' % (description, e, cmd_str, str(env)))
        return -1
    try:
        if timeout:
            deadtime = _time_begin + timeout
            while time.time() < deadtime and ret.poll() is None:
                time.sleep(poll_time)
        else:
            print "In Container "
            ret.wait()
            print "Out Container "

    except KeyboardInterrupt:
        ret.send_signal(signal.SIGINT)
        logging.error('Aborted by user.')
        return -1

    _exec_time = int((time.time() - _time_begin) * 1000)  # ms

    if ret.poll() is None:
        ret.send_signal(signal.SIGINT)
        logging.error(
            '%s : Exec [%s] overtime.' % (description, cmd_str))
        return -_exec_time

    if not show_message:
        for line in ret.stdout:
            if line:
                logging.info('%s %s' % (description, line.strip('\n')))
        for line in ret.stderr:
            if line:
                logging.error('%s %s' % (description, line.strip('\n')))

    if ret.returncode == 0:
        return _exec_time
    else:
        return -_exec_time

if __name__ == '__main__':
    main()