# Use lightweight Python image
FROM python:3.11-slim

# Install dependencies
RUN pip install boto3 prometheus-client

# Set working directory
WORKDIR /app

# Copy your exporter script
COPY aws_exporter.py /app/aws_exporter.py

# Run exporter
CMD ["python", "/app/aws_exporter.py"]
