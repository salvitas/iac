// ECS Roles and Policies
resource "aws_iam_role" "ecs_execution_role" {
  name               = var.ecs_execution_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_role_policy_attachment" "AmazonECSTaskExecutionRolePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_execution_role.name
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = var.ecs_task_execution_role_name
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_to_dynamodb_policy" {
  name = "ECSDynamoDBAccessPolicy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/*_${terraform.workspace}"
      },
    ]
  })
}

resource "aws_iam_role_policy" "ecs_to_sqs_policy" {
  name = "ECSSQSAccessPolicy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action = [
          "sqs:*"
        ]
        Resource = "arn:aws:sqs:*:*:*_${terraform.workspace}"
      },
    ]
  })
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = var.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_security_group" "ecs_sg" {
  name = "ecs_security_group_${terraform.workspace}"
  description = "ECS Security Group to allow access from ALB SG"
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "HTTP"
    security_groups = [var.elb_sg_id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "ecs_security_group_${terraform.workspace}"
  }
}

// Microservice specific config - testing
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/accounts-service-${terraform.workspace}"
}

resource "aws_ecs_task_definition" "accounts_service_task_definition" {
  family = "accounts_task_definition_${terraform.workspace}"
  requires_compatibilities = ["FARGATE"]
  memory = "512"
  cpu = "256"
  network_mode = "awsvpc"
  execution_role_arn = aws_iam_role.ecs_execution_role.arn
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = templatefile("${path.module}/data/container-definition.tpl", { container_name = "container_accounts", env = "${terraform.workspace}" })
}

resource "aws_lb_target_group" "accounts_tg" {
  name = "accounts-tg-${terraform.workspace}"
  vpc_id = var.vpc_id
  target_type = "ip"
  port = 80
  protocol = "HTTP"
  health_check {
    enabled = true
    interval = 30
    timeout = 25
    healthy_threshold = 2
    unhealthy_threshold = 10
    protocol = "HTTP"
    port = "80"
    path = "/accounts-service/actuator/health"
    matcher = "200"
  }
}

resource "aws_lb_listener_rule" "header_listener" {
  depends_on = [aws_lb_target_group.accounts_tg]
  listener_arn = var.alb_listener_arn
  priority     = 2

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.accounts_tg.arn
  }

  condition {
    http_header {
      http_header_name = "microservice"
      values = ["accounts"]
    }
  }
}

resource "aws_ecs_service" "accounts_service" {
  name            = "accounts_service_${terraform.workspace}"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.accounts_service_task_definition.arn
  desired_count   = 1
  propagate_tags = "TASK_DEFINITION"
  launch_type = "FARGATE"
  health_check_grace_period_seconds = 130
//  iam_role        = aws_iam_role.foo.arn
//  depends_on      = [aws_iam_role_policy.foo]
  network_configuration {
    assign_public_ip = true
    subnets = var.private_subnets
    security_groups = [aws_security_group.ecs_sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.accounts_tg.arn
    container_name   = var.container_name
    container_port   = 80
  }

}