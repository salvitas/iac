// TODO output the relations of the VPC configurations
output "elb_url" {
  value = aws_lb.alb.dns_name
}