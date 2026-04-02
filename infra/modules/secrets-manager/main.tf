resource "aws_secretsmanager_secret" "cornerstone_secrets" {
  name        = var.secret_name
  description = "cornerstone-secrets"

  tags = {
    map-migrated = "mig26763"
    aws-apn-id = "pc:dnoqxvh7zl6xavjod5heyxh77"
    environment = "Prod"
  }
}
