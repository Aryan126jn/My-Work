# Terraform + Jenkins + Docker + AWS (ECR + Lambda)

## 📌 Project Overview
This project demonstrates a complete DevOps workflow using:
- **Terraform** → Provision AWS resources (EC2, IAM, ECR, Lambda)
- **Jenkins** → CI/CD pipeline (running inside Docker on EC2)
- **Docker** → Containerize application
- **AWS Lambda** → Deploy serverless app from ECR
- **GitHub** → Code + pipeline configs

## 🎯 Goal
End-to-end CI/CD pipeline:
1. Code is pushed to GitHub
2. Jenkins builds Docker image
3. Image pushed to AWS ECR
4. Lambda function updated with new container image

## 📂 Folder Structure
- `terraform/` → Terraform IaC configs
- `app/` → Sample application + Dockerfile
- `jenkins/` → Jenkins setup + pipeline configs
- `docs/` → Architecture diagrams + screenshots

---
