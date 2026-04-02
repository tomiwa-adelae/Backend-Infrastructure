variable "db_instance_class" { default = "db.t4g.small" }
variable "db_engine_version" { default = "17.6" }
variable "db_allocated_storage" { default = 20 }

variable "db_name" {}
variable "db_username" {}

variable "private_subnet_ids" {}
variable "rds_security_group_id" {}
variable "app_secret_arn" {
  description = "Existing Secrets Manager ARN used by ECS"
  type        = string
}