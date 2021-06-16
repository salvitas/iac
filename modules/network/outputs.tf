output "elb_url" {
  value = "http://${aws_lb.alb.dns_name}"
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "elb_sg_id" {
  value = aws_security_group.elb_sg.id
}

output "private_subnets" {
  value = [aws_subnet.priv_sub_b.id, aws_subnet.priv_sub_a.id]
}

output "alb_listener_arn" {
  value = aws_lb_listener.alb_listener.arn
}