provider "aws" {
  region = var.region
  # profile = "cornerstone"
}

# VPC 
module "vpc" {
  source               = "./modules/vpc"
  cidr_block           = var.cidr_block
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

}

# ALB 
module "alb" {
  source              = "./modules/alb"
  subnets             = module.vpc.public_subnets
  security_groups     = [module.vpc.alb_security_group_id]
  vpc_id              = module.vpc.vpc_id
  acm_certificate_arn = var.acm_certificate_arn
}


# S3 
module "s3" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
}

# Secrets Manager 
module "secrets-manager" {
  source      = "./modules/secrets-manager"
  secret_name = "cornerstone-secrets-production"
}

# CloudWatch 
module "cloudwatch" {
  source = "./modules/cloudwatch"
}

# RDS
module "rds" {
  source = "./modules/rds"

  db_name     = "cornerstone_dbs"
  db_username = "db_admin"

  private_subnet_ids    = module.vpc.private_subnets
  rds_security_group_id = module.vpc.rds_security_group_id
  app_secret_arn        = module.secrets-manager.cornerstone_secrets_arn
}


# ECS backend Service
module "ecs" {
  source             = "./modules/ecs"
  cluster_name       = "cornerstone-ecs-cluster"
  task_family        = "backend-task-family"
  container_name     = "cornerstone-backend-container"
  container_image    = "055533306852.dkr.ecr.eu-west-1.amazonaws.com/cornerstone"
  container_port     = 8000
  subnets            = module.vpc.public_subnets
  security_group     = module.vpc.ecs_security_group_id
  desired_count      = 1
  target_group_arn   = module.alb.backend_target_group_arn
  region             = var.region
  secret_manager_arn = module.secrets-manager.cornerstone_secrets_arn
}






