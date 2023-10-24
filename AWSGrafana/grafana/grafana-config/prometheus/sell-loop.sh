#!/bin/bash

#Loop to check task after every 10 mins

x=$(aws ecs list-tasks --cluster proc-prod-V2 --service-name proc-be-sellerportal-V2 --desired-status RUNNING --query taskArns[] | jq -r '.[]' | tr -d '[]')

while true; do
  
 if [ "$x" = "$y" ]; then
    
 sleep 300 
 
 else
   
 y=$(aws ecs list-tasks --cluster proc-prod-V2 --service-name proc-be-sellerportal-V2 --desired-status RUNNING --query taskArns[] | jq -r '.[]' | tr -d '[]')

 
 
 bash /root/proc-be-grafana/grafana-config/prometheus/sell.sh

 docker compose -f  /root/proc-be-grafana/grafana-config/docker-compose.yml up
   
 fi

 x=$(aws ecs list-tasks --cluster proc-prod-V2 --service-name proc-be-sellerportal-V2 --desired-status RUNNING --query taskArns[] | jq -r '.[]' | tr -d '[]')

done  
