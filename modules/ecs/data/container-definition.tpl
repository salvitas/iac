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
        "value": "dev"
      },
      {
        "name": "amazon.dynamodb.accounts-table",
        "value": "accounts_dev"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "/ecs/accounts-service-${env}",
        "awslogs-region": "ap-southeast-1",
        "awslogs-stream-prefix": "accounts-service"
      }
    }
  }
]