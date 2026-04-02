output "cornerstone_secrets_arn" {
  description = "ARN of the cornerstone Secrets Manager Secret"
  value       = aws_secretsmanager_secret.cornerstone_secrets.arn
}
