First we create the base components for an environment:
S3 bucket
AWS_CF_Environment_network.yaml
AWS_CF_Environment_ALB.yaml
AWS_CF_Environment_ECScluster.yaml
[optional] AWS_CF_Environment_NATgateway.yaml -> Conditions: CreateNATGateway: !Equals [ !Ref CreateNAT, "True" ]
AWS_CF_Environment_SQS.yaml


"//virtual-banking/bank-as-a-service/services/dynamoDb:BankFast-dynamoDb",
"//virtual-banking/bank-as-a-service/services/appSync/bankfast:BankFast-appSync",
"//components/brick-types/technical/cloudfront:BankFast-cloudfront",


https://docs.cloudposse.com/reference/best-practices/terraform-best-practices/
https://docs.cloudposse.com/reference/best-practices/terraform-tips-tricks/

We use workspaces to define different variables for different environments [dev, prod]
terraform workspace new dev
terraform workspace new prod
terraform workspace list

## Usage
terraform init
terraform plan -var-file dev.tfvars
terraform apply -var-file dev.tfvars -auto-approve
terraform destroy -var-file dev.tfvars -auto-approve