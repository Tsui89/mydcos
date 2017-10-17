#!/usr/bin/env bash

CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o monitor .
docker build -t dev.k2data.com.cn:5001/ops/monitor-dcos:0.1 .