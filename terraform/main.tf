provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# ------------------------
# Networking
# ------------------------

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}

# Subnet
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

# Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Route Table Association
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# ------------------------
# Security Group
# ------------------------
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins UI
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # App port
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ------------------------
# ECR Repository
# ------------------------
resource "aws_ecr_repository" "app_repo" {
  name                 = "fortune-cookie"
  image_tag_mutability = "MUTABLE"
}

# ------------------------
# IAM Role for EC2 (ECR Push + SSM + EC2 Describe)
# ------------------------
resource "aws_iam_role" "ec2_fortuneapp_role" {
  name = "ec2-fortuneapp-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ec2_fortuneapp_policy" {
  name        = "ec2-fortuneapp-policy"
  description = "Allow EC2 to push Docker to ECR and use SSM"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ssm:SendCommand",
          "ssm:ListCommands",
          "ssm:GetCommandInvocation",
          "ssm:DescribeInstanceInformation"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role       = aws_iam_role.ec2_fortuneapp_role.name
  policy_arn = aws_iam_policy.ec2_fortuneapp_policy.arn
}

resource "aws_iam_instance_profile" "ec2_fortuneapp_profile" {
  name = "ec2-fortuneapp-profile"
  role = aws_iam_role.ec2_fortuneapp_role.name
}

# ------------------------
# Fetch latest Amazon Linux 2 AMI dynamically
# ------------------------
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ------------------------
# EC2 Instance (Jenkins & App)
# ------------------------
resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro" # free tier eligible
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_fortuneapp_profile.name

  tags = {
    Name = "JenkinsServer"
    Role = "FortuneApp"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Install Docker if not present
              if ! command -v docker &> /dev/null; then
                  yum update -y
                  amazon-linux-extras install docker -y
                  service docker start
                  usermod -a -G docker ec2-user
              fi
              EOF
}

# ------------------------
# Outputs
# ------------------------
output "ec2_public_ip" {
  value = aws_instance.jenkins_server.public_ip
}

output "ecr_repo_url" {
  value = aws_ecr_repository.app_repo.repository_url
}
