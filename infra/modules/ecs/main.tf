# CloudWatch Log Group for ECS
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.task_family}"
  retention_in_days = 7
  
  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}


resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.task_family}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Policy to allow read/write access to S3 buckets and access Secrets Manager
resource "aws_iam_policy" "ecs_s3_secrets_access_policy" {
  name        = "${var.task_family}-S3SecretsAccessPolicy"
  description = "Allow ECS tasks to read/write S3 buckets and access Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = [
          "arn:aws:s3:::*",
          "arn:aws:s3:::*/*",
          "arn:aws:logs:*:*:log-group:/ecs/${var.task_family}:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = var.secret_manager_arn
      }
    ]
  })
  
  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

# Attach S3 and Secrets Manager access policy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_s3_secrets_access_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_s3_secrets_access_policy.arn
}

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
  
  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  
  memory                   = "512"  
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  # added runtime_platform
  runtime_platform {
    cpu_architecture        = "ARM64"
    operating_system_family = "LINUX"
  }
  
  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
  
  container_definitions = templatefile("${path.module}/${var.task_definition_file}", {
    secret_arn = var.secret_manager_arn
  })
  
  volume {
    name = "uploads"
  }
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"
  
  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }

  network_configuration {
    subnets          = var.subnets
    assign_public_ip = true
    security_groups  = [var.security_group]
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_ecs_task_definition.this]
}
