# Manara-AWS Infrastructure
This repository holds the **Infrastructure as Code (IaC)** definitions for the Manara b2b and backend applications, deployed on AWS. It enables provisioning, updating, and managing the application's foundation in a reproducible, secure, and scalable manner.

## High level Architecture
- insert architecture link

This architecture covers: 
- Application compute via **ECS Fargate**
- Data storage in **RDS** (with a read replica for scale)
- Traffic routing via **ALB**, DNS via **Route 53**, and security layer via **WAF**, and security groups.
- Monitoring and alerting via **Cloudwatch**

## Repo structure
```
├── README.md
├── infra
│   ├── backend.tf
│   ├── main.tf
│   ├── modules
│   │   ├── alb/
│   │   ├── cloudwatch/
│   │   ├── ecs/
│   │   │   ├── main.tf/
│   │   │   ├── task-definitions
│   │   │   │   └── backend-service.json
│   │   ├── rds/
│   │   ├── redis/
│   │   ├── s3/
│   │   ├── secrets-manager/
│   │   ├── vpc/
│   │   └── waf/
│   ├── output.tf
│   ├── terraform.tfvars
│   ├── .github/
│   |    └── workflows/
│   └── variables.tf
└── infra.png
```
### Prerequisites
- AWS Account 
- AWS CLI and credentials
- Terraform CLI (version >=5.0)

## Setup
1. Clone the repo
```bash
git clone https://github.com/cornerstone/cornerstone-infra
cd infra
```
2. Create a `test-terraform.tfvars` file
```bash
region               = "preferred-region"
cidr_block           = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
availability_zones   = ["az1", "az2", "az3"] # Replace with the actual names


s3_bucket_name  = "<input-bucket-name>"


auth_token = "<input-strong-password>"

rds_db_name           = "<name>"
rds_username          = "<db-username>"
rds_password          = "<db-password>"
rds_instance_class    = "db.t4g.medium"
rds_allocated_storage = 20


acm_certificate_arn = "<copy-arn-from-the-management-console>"
```
3. Deploy the infrastructure

```bash
terraform init
```

```
terraform plan -var-file=dev-terraform.tfvars
```

```
terraform apply -var-file=dev-terraform.tfvars
```

## Operational goals
This infrastructure aims to meet the following goals:
- Scalability
- High Availability
- Cost Efficiency (pay-as-you-go)
- Security & Compliance
- Automated Deployments / CI/CD
- Monitoring & Alerting


