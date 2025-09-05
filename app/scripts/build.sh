#!/bin/bash
set -e  # exit immediately if a command fails

IMAGE_NAME="fortune-cookie-app"

echo "🔨 Building Docker image: $IMAGE_NAME ..."
docker build -t $IMAGE_NAME .
echo "✅ Build complete!"
