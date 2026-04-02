resource "random_password" "db_password" {
  length  = 20
  special = false
}

resource "aws_db_subnet_group" "this" {
  name       = "cornerstone-db-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_db_instance" "this" {
  identifier             = "cornerstone-postgres"
  engine                 = "postgres"
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.rds_security_group_id]

  publicly_accessible = false
  skip_final_snapshot = true

  tags = {
    Name = "cornerstone-postgres"
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

# Read existing app secret
data "aws_secretsmanager_secret_version" "current" {
  secret_id = var.app_secret_arn
}

# Inject RDS credentials into it
resource "aws_secretsmanager_secret_version" "db_injection" {
  secret_id = var.app_secret_arn

  secret_string = jsonencode(
    
      {
        DATABASE_HOST     = aws_db_instance.this.address
        DATABASE_PORT     = tostring(aws_db_instance.this.port)
        DATABASE_NAME     = var.db_name
        DATABASE_USER     = var.db_username
        DATABASE_PASSWORD = random_password.db_password.result
        DATABASE_URL      = "postgresql://${var.db_username}:${random_password.db_password.result}@${aws_db_instance.this.address}:${aws_db_instance.this.port}/${var.db_name}"
      }
  )

  depends_on = [aws_db_instance.this]
}


