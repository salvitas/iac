[
  {
    "name": "${container_name}",
    "image": "411183860942.dkr.ecr.ap-southeast-1.amazonaws.com/bankstart/accounts-service:0.0.1-SNAPSHOT",
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "environment": [
      {
        "name": "env",
        "value": "${env}"
      },
      {
        "name": "amazon.dynamodb.accounts-table",
        "value": "${table_name}"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "ap-southeast-1",
        "awslogs-stream-prefix": "accounts-service"
      }
    }
  }
]