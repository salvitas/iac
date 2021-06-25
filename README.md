# Terraform for BankStart Infrastructure (current provider = AWS)

This project provides a way to bootstrap the whole infrastructure needed to run bankstart in AWS.
The following components will be used:
- AWS VPC
- AWS Subnet (2x private , 2x public)
- AWS EIP (1 public IP)
- AWS NAT Gateway (1x) 
- AWS ALB (LoadBalancer for microservices)
- AWS Route53 (Hosted Zone and A record) 
- AWS CloudFront
- AWS AppSync
- AWS Cognito
- AWS Lambda
- AWS S3 (website and mobile app)
- AWS ECR
- AWS ECS
- AWS DynamoDB
- AWS IAM and Policies
- AWS Certificate Manager

## Requirements
| Name | Version |
|------|---------|
| terraform | 1.1.x |
| aws | 3.46.x |


## Usage
```bash
terraform init
terraform plan -var-file dev.tfvars
terraform apply -var-file dev.tfvars -auto-approve
terraform destroy -var-file dev.tfvars -auto-approve
```

### Terraform Workspaces
We use workspaces to define different variables for different environments [dev, prod]
```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace list
terraform workspace select dev
```

### Sample dev.tfvars
```bash
region           = "ap-southeast-1"
namespace        = "bankstart"
cert_name        = "bankfastdemo.com"
hosted_zone_name = "bankfastdemo.com"
web_bucket_name  = "staticwebcontent"
pool_name        = "users"
api_name         = "api"
```

## Useful links
- [CloudPosse Terraform best practices](https://docs.cloudposse.com/reference/best-practices/terraform-best-practices/)
- [CloudPosse Terraform Tips](https://docs.cloudposse.com/reference/best-practices/terraform-tips-tricks/)
- [Terraform best practices](https://github.com/ozbillwang/terraform-best-practices/blob/master/README.md)
- [Awesome Terraform](https://github.com/shuaibiyy/awesome-terraform/blob/master/README.md)