# 🚀 AWS CI/CD Pipeline with Terraform & ECS

A fully automated cloud deployment pipeline that demonstrates modern DevOps practices using AWS services, Terraform infrastructure-as-code, and GitHub Actions CI/CD. This project focuses on showcasing the complete end-to-end automation flow rather than building a production-grade application.

## ✨ Features

- **Infrastructure as Code**: Complete AWS infrastructure provisioned with Terraform
- **Containerized Deployment**: Docker-based application deployment on ECS
- **Automated CI/CD**: Zero-touch deployment pipeline with GitHub Actions
- **Cloud-Native Architecture**: Leverages AWS ECR, ECS, EC2, and IAM services
- **Fast Deployment**: End-to-end deployment in under 2 minutes
- **Production-Ready Infrastructure**: Includes proper networking, security, and scaling configurations

## 🛠️ Tech Stack

- **Cloud Provider**: Amazon Web Services (AWS)
- **Infrastructure**: Terraform
- **Container Orchestration**: Amazon ECS on EC2
- **Container Registry**: Amazon ECR
- **CI/CD**: GitHub Actions
- **Application**: Python (simple demonstration app)
- **Containerization**: Docker
- **Networking**: VPC, Subnets, Security Groups
- **Identity & Access**: IAM Roles and Policies

## 🏗️ Architecture Flow

```
Developer Push → GitHub Actions → Docker Build → ECR Push → ECS Update → EC2 Deployment
```

1. **Code Push**: Developer pushes code changes to GitHub repository
2. **CI Trigger**: GitHub Actions workflow automatically triggers
3. **Image Build**: Docker image is built with latest application code
4. **Registry Push**: Built image is pushed to Amazon ECR
5. **Service Update**: ECS service and task definition are automatically updated
6. **Container Deploy**: EC2 instances pull and run the new container image
7. **Live Application**: Updated application is live and accessible

## ⚙️ How It Works

### Infrastructure Provisioning
Terraform creates and manages all AWS resources including:
- **ECR Repository**: Stores Docker images
- **ECS Cluster**: Manages container orchestration on EC2 instances
- **VPC & Networking**: Secure network configuration with subnets and security groups
- **IAM Roles**: Proper permissions for services to interact securely
- **Load Balancer**: Distributes traffic across container instances

### Continuous Integration/Deployment
The GitHub Actions pipeline automates the entire deployment process:
- Builds Docker image on every code push
- Pushes image to ECR with proper tagging
- Updates ECS task definition with new image
- Triggers rolling deployment with zero downtime
- Provides deployment status and rollback capabilities

## 🎯 Project Focus

This project prioritizes demonstrating the **complete automation workflow** rather than building a complex application or enterprise-level production setup. The Python application serves as a simple vehicle to showcase:

- End-to-end CI/CD automation
- Infrastructure as Code principles
- Cloud-native deployment patterns
- DevOps best practices integration

The emphasis is on the **flow and automation mechanics** that can be applied to any application, making it a valuable learning and demonstration tool for modern deployment practices.

## 🎬 Demo

https://www.linkedin.com/posts/aryanshrma_cloudcomputing-aws-devops-activity-7370475834849021952-vscH?utm_source=share&utm_medium=member_desktop&rcm=ACoAADg9FfkBNz-Tol5wzSLpomQVtLk_A6nUK00



## 💡 Why This Project Matters

This project demonstrates essential DevOps and cloud engineering skills that are highly valued in modern software development:

- **Real-World Relevance**: Mirrors production deployment patterns used by tech companies
- **Scalability**: Architecture supports horizontal scaling and high availability
- **Automation**: Reduces manual errors and deployment time from hours to minutes
- **Maintainability**: Infrastructure as code ensures consistent and repeatable deployments
- **Cloud Expertise**: Showcases deep understanding of AWS services integration
- **DevOps Proficiency**: Demonstrates modern CI/CD pipeline design and implementation

Perfect for showcasing cloud architecture knowledge, DevOps automation skills, and understanding of modern deployment practices to potential employers or clients.

## 🎯 Key Learning Outcomes

- Infrastructure as Code with Terraform
- Container orchestration with Amazon ECS
- CI/CD pipeline design and implementation
- AWS cloud services integration
- Docker containerization best practices
- GitHub Actions workflow automation
- Cloud security and networking fundamentals
- End-to-end automation workflow design

## 👨‍💻 Author

**Aryan Sharma**
- LinkedIn: www.linkedin.com/in/aryanshrma


---

⭐ If you found this project helpful, please give it a star! It helps others discover this work and supports continued development.
