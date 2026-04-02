output "vpc_id" {
  value = module.vpc.vpc_id
}
output "alb_dns_name" {
  value = module.alb.dns_name
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}
#output "rds_endpoint" {
# value = module.rds.rds_endpoint
#}