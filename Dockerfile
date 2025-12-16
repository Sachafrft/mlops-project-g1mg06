# 1. Base Image (Official Python)
FROM python:3.9-slim

# 2. Set working directory
WORKDIR /app

# 3. Copy dependencies first (for caching speed)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy the application code
COPY src/ src/

# 5. Define the command to run the API
# We use host 0.0.0.0 to make it accessible outside the container
CMD ["uvicorn", "src.api.app:app", "--host", "0.0.0.0", "--port", "8000"]