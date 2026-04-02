region               = "eu-west-1"
cidr_block           = "30.0.0.0/16"
public_subnet_cidrs  = ["30.0.1.0/24", "30.0.2.0/24"]
private_subnet_cidrs = ["30.0.3.0/24", "30.0.4.0/24", "30.0.5.0/24"]
availability_zones   = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]


s3_bucket_name = "cornerstone-2026-bucket"
#state_s3_bucket = "cornerstone-terraform-state-bucket"


auth_token = "StrongPasswd123!"

rds_db_name           = "cornerstone"
rds_username          = "root"
rds_password          = "pas#sword123!"
rds_instance_class    = "db.t4g.medium"
rds_allocated_storage = 20

acm_certificate_arn = "arn:aws:acm:eu-west-1:997241706245:certificate/dff0857e-23e9-4f10-ba58-6acf0dd74e2f"


