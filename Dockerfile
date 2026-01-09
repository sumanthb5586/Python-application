# Stage 1: Build stages
FROM python:3.12-slim AS build

# Set working directory
WORKDIR /app

# Install build dependencies (if any)
RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency file
COPY requirements.txt .

# Install Python dependencies into /app/.venv (isolated virtual env)
RUN python -m venv /app/.venv \
    && /app/.venv/bin/pip install --upgrade pip \
    && /app/.venv/bin/pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Stage 2: Production runtime
FROM python:3.12-slim

# Create a non-root user
RUN useradd -m appuser

# Set working directory
WORKDIR /app

# Copy virtual environment and app code from build stage
COPY --from=build /app /app

# Ensure non-root user owns the files
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Set environment variables for production
ENV PATH="/app/.venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Expose the backend port
EXPOSE 8000

# Command to run the app (FastAPI example)
CMD ["python","app.py"]

