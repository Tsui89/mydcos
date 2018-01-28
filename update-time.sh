#!/usr/bin/env bash


#!/bin/bash

service ntpd stop

ntpdate 192.168.131.1

service ntpd restart