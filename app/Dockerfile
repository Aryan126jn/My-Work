# Use AWS Lambda Python 3.11 base image
FROM public.ecr.aws/lambda/python:3.11

# Copy dependency list
COPY requirements.txt .

# Install dependencies into Lambda task root
RUN pip install --no-cache-dir -r requirements.txt --target "${LAMBDA_TASK_ROOT}"

# Copy app source code
COPY src/ ${LAMBDA_TASK_ROOT}

# Set the CMD to your handler (file name without .py + function name)
# Example: app.py file has "def lambda_handler(event, context):"
CMD ["app.lambda_handler"]
