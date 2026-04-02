resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = 30

  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}

