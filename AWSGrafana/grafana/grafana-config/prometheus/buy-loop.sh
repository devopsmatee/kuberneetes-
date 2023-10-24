#!/bin/bash


# Get arn of the task
task_arn=$(aws ecs list-tasks --cluster proc-prod-V2 --service-name proc-be-buyerportal-V2 --desired-status RUNNING --query taskArns[] | jq -r '.[]' | tr -d '[]')

while true; do
  
 if [ "$task_arn" = "$y" ]; then
    
 sleep 300 
 
 else
   
 y=$(aws ecs list-tasks --cluster proc-prod-V2 --service-name proc-be-buyerportal-V2 --desired-status RUNNING --query taskArns[] | jq -r '.[]' | tr -d '[]')

 sleep 300

 # Extract the task ID from the arn of the task
 task_id=$(echo "$task_arn" | cut -d '/' -f 3)

 # Get the IP address of task
 ip_address=$(aws ecs describe-tasks --cluster proc-prod-V2 --tasks $task_arn --query 'tasks[].containers[].networkInterfaces[].privateIpv4Address' | jq -r '.[]' | tr -d '[]')

 # Get task defination revision arn
 task_definiton_arn=$(aws ecs describe-tasks --cluster proc-prod-V2 --tasks $task_arn --query tasks[].taskDefinitionArn | jq -r '.[]' | tr -d '[]')

 #Extract the task definition revision ID from revision arn
 revision_id=$(echo "$task_definiton_arn" | awk -F':' '{print $NF}')

 # Define the JSON data
 json_data=$(cat <<EOF
 [
  {
    "targets": ["${ip_address}:8093"],
    "labels": {
      "__meta_ecs_task_arn": "arn:aws:ecs:me-south-1:501175596353:task/proc-prod-V2/${task_id}",
      "__meta_ecs_task_definition_family": "proc-be-buyerportal-V2",
      "__meta_ecs_task_definition_revision": "${revision_id}",
      "application": "Be-Buyer"
    }
  }
 ]
 EOF
 )

 docker compose -f  /root/proc-be-grafana/grafana-config/docker-compose.yml up
  
 fi

 done  
