# Use lightweight Python base image
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy exporter script
COPY mock_cost_exporter.py .

# Install dependencies
RUN pip install prometheus_client

# Expose port for metrics
EXPOSE 8000

# Run exporter
CMD ["python", "mock_cost_exporter.py"]
