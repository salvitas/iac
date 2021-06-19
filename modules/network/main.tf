// Create Main VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "bankstart_vpc_${terraform.workspace}"
  }
}

// Create Private Subnet A
resource "aws_subnet" "priv_sub_a" {
  depends_on = [aws_vpc.vpc]
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.priv_sub_a_cidr
  // cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = "ap-southeast-1a"
  tags = {
    Name = "bankstart_privatesubnet_a_${terraform.workspace}"
  }
}
// Create Private Subnet B
resource "aws_subnet" "priv_sub_b" {
  depends_on = [aws_vpc.vpc]
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.priv_sub_b_cidr
  // cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = "ap-southeast-1b"
  tags = {
    Name = "bankstart_privatesubnet_b_${terraform.workspace}"
  }
}

// Create Public Subnet A
resource "aws_subnet" "pub_sub_a" {
  depends_on = [
    aws_vpc.vpc]
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pub_sub_a_cidr
  //cidrsubnet(aws_vpc.vpc.cidr_block, 8, 2)
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "bankstart_publicsubnet_a_${terraform.workspace}"
  }
}
// Create Public Subnet B
resource "aws_subnet" "pub_sub_b" {
  depends_on = [
    aws_vpc.vpc]
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.pub_sub_b_cidr
  //cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)
  availability_zone = "ap-southeast-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "bankstart_publicsubnet_b_${terraform.workspace}"
  }
}

// Create an IGW and attach it to VPC
resource "aws_internet_gateway" "igw" {
  depends_on = [
    aws_vpc.vpc]
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "bankstart_igw_${terraform.workspace}"
  }
}

resource "aws_route_table" "public_rt" {
  depends_on = [
    aws_vpc.vpc]
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "bankstart_public_${terraform.workspace}"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.pub_sub_a.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "b" {
  subnet_id = aws_subnet.pub_sub_b.id
  route_table_id = aws_route_table.public_rt.id
}

// Create 2 Elastic IPs and 2 NAT gateways to be placed in respective public subnets. Associate the EIPs with NAT gateways.
resource "aws_eip" "eip_natgw1" {
  count = "1"
}
resource "aws_nat_gateway" "natgateway_1" {
  count = "1"
  allocation_id = aws_eip.eip_natgw1[count.index].id
  subnet_id = aws_subnet.pub_sub_a.id
  tags = {
    Name = "bankstart_natgw_a_${terraform.workspace}"
  }
}

// Commenting out 1 NAT GW and pointing priv subnet b t NAT GW A (keep cost down)

//resource "aws_eip" "eip_natgw2" {
//  count = "1"
//}
//resource "aws_nat_gateway" "natgateway_2" {
//  count = "1"
//  allocation_id = aws_eip.eip_natgw2[count.index].id
//  subnet_id = aws_subnet.pub_sub_b.id
//  tags = {
//    Name = "bankstart_natgw_b_${terraform.workspace}"
//  }
//}

# Create private route tables and NAT associations
resource "aws_route_table" "priv_sub_a_rt" {
  count  = "1"
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1[count.index].id
  }
  tags = {
    Name = "bankstart_private_a_${terraform.workspace}"
  }
}
resource "aws_route_table_association" "priv_sub_a_to_natgw1" {
  count          = "1"
  route_table_id = aws_route_table.priv_sub_a_rt[count.index].id
  subnet_id      = aws_subnet.priv_sub_a.id
}

resource "aws_route_table" "priv_sub_b_rt" {
  count  = "1"
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgateway_1[count.index].id
  }
  tags = {
    Name = "bankstart_private_b_${terraform.workspace}"
  }
}
resource "aws_route_table_association" "priv_sub_b_to_natgw2" {
  count          = "1"
  route_table_id = aws_route_table.priv_sub_b_rt[count.index].id
  subnet_id      = aws_subnet.priv_sub_b.id
}

// Create security group for load balancer
resource "aws_security_group" "elb_sg" {
  depends_on = [aws_vpc.vpc]
  name = "${var.sg_name}_${terraform.workspace}"
  description = "ALB Security Group to access ECS from Public Subnet"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    description = "HTTP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
    ipv6_cidr_blocks = [
      "::/0"]
  }

  tags = {
    Name = "${var.sg_name}_${terraform.workspace}"
  }
}

// Create Target group
resource "aws_lb_target_group" "target_group" {
  name = "bankstart-tg-${terraform.workspace}"
  depends_on = [aws_vpc.vpc]
  vpc_id = aws_vpc.vpc.id
  port = 80
  protocol = "HTTP"
  target_type = "ip"

  //  health_check {
  //    interval            = 70
  //    path                = "/index.html"
  //    port                = 80
  //    healthy_threshold   = 2
  //    unhealthy_threshold = 2
  //    timeout             = 60
  //    protocol            = "HTTP"
  //    matcher             = "200,202"
  //  }
}
// Application Load Balancer
resource "aws_lb" "alb" {
  name = "bankstart-alb-${terraform.workspace}"
  internal = false
  load_balancer_type = "application"
  security_groups = [
    aws_security_group.elb_sg.id]
  subnets = [
    aws_subnet.pub_sub_a.id,
    aws_subnet.pub_sub_b.id]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port = "80"
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not found a service to map your microservice header"
      status_code = "404"
    }
  }
}