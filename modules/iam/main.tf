//// EKS Roles and Policies
//resource "aws_iam_role" "eks_role" {
//  name = var.eks_role_name
//  assume_role_policy = jsonencode({
//    Version = "2012-10-17"
//    Statement = [
//      {
//        Effect = "Allow"
//        Action = "sts:AssumeRole"
//        Principal = {
//          Service = "eks.amazonaws.com"
//        }
//      },
//    ]
//  })
//}
//
//resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
//  role       = aws_iam_role.eks_role.name
//}
//// Optionally, enable Security Groups for Pods
//// Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
//resource "aws_iam_role_policy_attachment" "AmazonEKSVPCResourceController" {
//  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
//  role       = aws_iam_role.eks_role.name
//}