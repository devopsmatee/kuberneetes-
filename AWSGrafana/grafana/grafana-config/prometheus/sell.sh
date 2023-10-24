#!/bin/bash

# Get arn of the task
task_arn=$(aws ecs list-tasks --cluster proc-prod-V2 --service-name proc-be-sellerportal-V2 --desired-status RUNNING --query taskArns[] | jq -r '.[]' | tr -d '[]')

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
    "targets": ["${ip_address}:8094"],
    "labels": {
      "__meta_ecs_task_arn": "arn:aws:ecs:me-south-1:501175596353:task/proc-prod-V2/${task_id}",
      "__meta_ecs_task_definition_family": "proc-be-sellerportal-V2",
      "__meta_ecs_task_definition_revision": "${revision_id}",
      "application": "Be-Seller-"
    }
  }
]
EOF
)

#Save the JSON data to a file
echo "$json_data" > seller-targets.json
