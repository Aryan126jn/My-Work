FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy application code
COPY src/ /app/

# Install dependencies if any
RUN pip install --no-cache-dir flask

# Expose port
EXPOSE 5000

# Run app
CMD ["python", "app.py"]
