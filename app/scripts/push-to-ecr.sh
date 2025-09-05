#!/bin/bash
# Script to build, tag, and push Docker image to AWS ECR

set -e

# Variables (update <AWS_ACCOUNT_ID>, <REGION>, and <REPO_NAME> later)
AWS_ACCOUNT_ID="<your-aws-account-id>"
REGION="us-east-1"
REPO_NAME="fortune-cookie-app"
IMAGE_TAG="latest"

# Full ECR repository URI
ECR_URI="$AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO_NAME:$IMAGE_TAG"

echo "🔑 Logging into Amazon ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "🏷️ Tagging Docker image..."
docker tag fortune-cookie-app:$IMAGE_TAG $ECR_URI

echo "📤 Pushing image to ECR..."
docker push $ECR_URI

echo "✅ Push complete! Image available at: $ECR_URI"
