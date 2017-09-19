#!/usr/bin/env python

import os
import sys
import time
import json
import urllib2
import urllib
import random

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

Master_Mesos = ["192.168.131.11","192.168.131.12","192.168.131.13"]

class AppS(object):

    def __init__(self, id, appId, host, state,**kwargs):
        self.Id = id
        self.AppId = appId
        self.Host = host
        self.State = state

class TaskR(object):

    def __init__(self, tasks):
        self.tasks = tasks

    def getAppS(self):
        for t in self.tasks:
            print t
            yield AppS(**t)

def main():
    if sys.argv < 1:
        print "need argument svc name"
    master = Master_Mesos[random.randint(0, 2)]

    app_url = "http://" + "/".join([master,"marathon","v2/apps", sys.argv[1],"tasks"])
    resp = urllib.urlopen(app_url)

    data = json.loads(resp.read())
    ts = TaskR(**data)

    for apps in ts.getAppS():
        print apps.Id

if __name__ == '__main__':
    main()