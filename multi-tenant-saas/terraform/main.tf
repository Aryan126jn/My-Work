terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

# ------------------------
# Provider
# ------------------------
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ------------------------
# Variables
# ------------------------
variable "aws_region" {
  description = "AWS region"
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  default     = "Aryan"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  default     = "my-keypair"
}

variable "cluster_name" {
  default = "mydaily-cluster"
}

variable "node_instance_type" {
  default = "t3.small"
}

variable "desired_capacity" {
  default = 1
}

variable "max_size" {
  default = 1
}

variable "min_size" {
  default = 1
}

variable "notes_image_tag" {
  default = "latest"
}

variable "expense_image_tag" {
  default = "latest"
}

# ------------------------
# Networking
# ------------------------
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { 
    Name = "mydaily-vpc"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "mydaily-igw" }
}

# Public Subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = { 
    Name = "mydaily-public-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = { 
    Name = "mydaily-public-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

# Private Subnets
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  tags = { 
    Name = "mydaily-private-a"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = { 
    Name = "mydaily-private-b"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# NAT Gateway for Private Subnets
resource "aws_eip" "nat_a" {
  domain = "vpc"
  tags   = { Name = "mydaily-nat-eip-a" }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
  tags          = { Name = "mydaily-nat-a" }
  depends_on    = [aws_internet_gateway.igw]
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "mydaily-public-rt" }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnets
resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }

  tags = { Name = "mydaily-private-rt-a" }
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_a.id
}

# ------------------------
# Security Groups
# ------------------------
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "eks-cluster-sg-"
  vpc_id      = aws_vpc.main.id
  description = "EKS cluster security group"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = "mydaily-eks-cluster-sg"
  }
}

resource "aws_security_group" "eks_nodes_sg" {
  name_prefix = "eks-node-sg-"
  vpc_id      = aws_vpc.main.id
  description = "Security group for EKS worker nodes"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = "mydaily-eks-nodes-sg"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# Allow nodes to communicate with cluster API
resource "aws_security_group_rule" "node_to_cluster" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
}

# Allow cluster to communicate with nodes
resource "aws_security_group_rule" "cluster_to_node" {
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}

resource "aws_security_group_rule" "cluster_to_node_kubelet" {
  type                     = "ingress"
  from_port                = 10250
  to_port                  = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_cluster_sg.id
}

# Allow nodes to communicate with each other
resource "aws_security_group_rule" "node_to_node" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes_sg.id
  source_security_group_id = aws_security_group.eks_nodes_sg.id
}

# Allow load balancer access
resource "aws_security_group_rule" "node_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
}

resource "aws_security_group_rule" "node_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.eks_nodes_sg.id
}

# ------------------------
# IAM Roles
# ------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "mydaily-eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_vpc_resource_controller" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

resource "aws_iam_role" "eks_node_role" {
  name = "mydaily-eks-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# Additional policy for SSM access (helpful for debugging)
resource "aws_iam_role_policy_attachment" "eks_ssm_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ------------------------
# EKS Cluster & Node Group
# ------------------------
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids = [
      aws_subnet.public_a.id,
      aws_subnet.public_b.id,
      aws_subnet.private_a.id,
      aws_subnet.private_b.id
    ]
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
    aws_iam_role_policy_attachment.eks_vpc_resource_controller
  ]
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "mydaily-nodegroup"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_a.id, aws_subnet.private_b.id]

  scaling_config {
    desired_size = var.desired_capacity
    min_size     = var.min_size
    max_size     = var.max_size
  }

  instance_types = [var.node_instance_type]
  disk_size      = 20

  # Add remote access if needed
  remote_access {
    ec2_ssh_key = var.key_name
    source_security_group_ids = [aws_security_group.eks_nodes_sg.id]
  }

  # Force update to latest AMI
  force_update_version = false

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
    aws_eks_cluster.eks,
    aws_nat_gateway.nat_a
  ]

  tags = {
    Name = "mydaily-eks-nodes"
  }
}

# ------------------------
# ECR Repositories
# ------------------------
resource "aws_ecr_repository" "notes_repo" {
  name                 = "notes-app"
  image_tag_mutability = "MUTABLE"
  
  force_delete = true

  tags = {
    Name = "notes-app-repo"
  }
}

resource "aws_ecr_repository" "expense_repo" {
  name                 = "expense-tracker"
  image_tag_mutability = "MUTABLE"
  
  force_delete = true

  tags = {
    Name = "expense-tracker-repo"
  }
}

# ------------------------
# Outputs
# ------------------------
output "eks_cluster_endpoint" {
  value       = aws_eks_cluster.eks.endpoint
  description = "Endpoint for EKS cluster"
}

output "eks_cluster_name" {
  value       = aws_eks_cluster.eks.name
  description = "EKS cluster name"
}

output "eks_cluster_security_group_id" {
  value       = aws_security_group.eks_cluster_sg.id
  description = "Security group ID for EKS cluster"
}

output "eks_node_security_group_id" {
  value       = aws_security_group.eks_nodes_sg.id
  description = "Security group ID for EKS nodes"
}

output "notes_ecr_repo_url" {
  value       = aws_ecr_repository.notes_repo.repository_url
  description = "URL for notes ECR repository"
}

output "expense_ecr_repo_url" {
  value       = aws_ecr_repository.expense_repo.repository_url
  description = "URL for expense tracker ECR repository"
}

output "configure_kubectl" {
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.eks.name} --profile ${var.aws_profile}"
  description = "Command to configure kubectl"
}