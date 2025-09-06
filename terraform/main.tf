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

  # Ingress: all ports open
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
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

# ECR Lifecycle Policy (keep last 5 images)
resource "aws_ecr_lifecycle_policy" "app_repo_policy" {
  repository = aws_ecr_repository.app_repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Keep last 5 images",
      "selection": {
        "tagStatus": "any",
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

# ------------------------
# ECS Cluster
# ------------------------
resource "aws_ecs_cluster" "fortune_cluster" {
  name = "fortune-cluster"
}

# ------------------------
# IAM Role for EC2
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

# Custom EC2 policy (mainly for ECR push, keep for demo completeness)
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
        Action = ["ec2:DescribeInstances"],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  role       = aws_iam_role.ec2_fortuneapp_role.name
  policy_arn = aws_iam_policy.ec2_fortuneapp_policy.arn
}

# Attach managed policies for ECS/ECR/SSM
resource "aws_iam_role_policy_attachment" "attach_ecs_instance_managed" {
  role       = aws_iam_role.ec2_fortuneapp_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "attach_ecr_read_managed" {
  role       = aws_iam_role.ec2_fortuneapp_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "attach_ssm_managed" {
  role       = aws_iam_role.ec2_fortuneapp_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_fortuneapp_profile" {
  name = "ec2-fortuneapp-profile"
  role = aws_iam_role.ec2_fortuneapp_role.name
}

# ------------------------
# ECS Task Execution Role (for Phase 2, created now)
# ------------------------
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Effect = "Allow"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_exec_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
# ------------------------
# ECS Task Definition (Phase 2, Step 1 - EC2-compatible)
# ------------------------
resource "aws_ecs_task_definition" "fortune_task" {
  family                   = "fortune-task"
  network_mode             = "bridge"       # EC2-compatible
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "400"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "fortune-container"
      image     = "${aws_ecr_repository.app_repo.repository_url}:${var.image_tag}" 
      cpu       = 256
      memory    = 400
      essential = true
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 0
          protocol = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/fortune"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}


# ------------------------
# Fetch ECS-optimized AMI
# ------------------------
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

# ------------------------
# EC2 Instance (ECS Node)
# ------------------------
resource "aws_instance" "jenkins_server" {
  ami                         = data.aws_ami.ecs_optimized.id
  instance_type               = "t2.micro" # free tier eligible
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.jenkins_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_fortuneapp_profile.name
  key_name                    = "my-keypair"  
  
   tags = {
    Name = "JenkinsServer"
    Role = "FortuneApp"
  }

  user_data = <<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.fortune_cluster.name} >> /etc/ecs/ecs.config
              systemctl enable --now ecs || true
              yum install -y amazon-ssm-agent || true
              systemctl enable --now amazon-ssm-agent || true
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
