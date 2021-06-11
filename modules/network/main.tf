//resource "aws_vpc" "vpc" {
//  cidr_block = "10.1.0.0/16"
//}
//
//resource "aws_subnet" "subnet" {
//  vpc_id = aws_vpc.vpc.id
//
////  availability_zone = "us-west-2b"
//  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 4, 1)
//}