output "db_host" {
  value = aws_db_instance.this.address
}

output "db_port" {
  value = aws_db_instance.this.port
}

output "db_name" {
  value = var.db_name
}

output "db_user" {
  value = var.db_username
}

output "db_password" {
  value     = random_password.db_password.result
  sensitive = true
}
