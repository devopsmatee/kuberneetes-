#!/bin/bash

sleep 30

#build prometheus-grafana container

docker compose -f  /root/proc-be-grafana/grafana-config/docker-compose.yml up
