# Use an official Python 3.12 base image
FROM python:3.12-slim

# Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PATH="/root/.local/bin:$PATH"

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    libpq-dev \
    && python -m pip install --upgrade pip setuptools \
    && python -m pip install pipx \
    && pipx ensurepath \
    && apt-get purge -y --auto-remove build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry using pipx
RUN pipx install poetry

# Set work directory
WORKDIR /app

# Clone the repository with a specific tag
RUN git clone --depth 1 --branch v3.2.30 https://github.com/SciPhi-AI/R2R.git /app/R2R

# Install R2R dependencies using Poetry
WORKDIR /app/R2R/py
RUN poetry install --extras core
RUN poetry install --extras ingestion-bundle

# Expose application ports
EXPOSE 8000
EXPOSE 7272

# Set the command to run the application
CMD ["poetry", "run", "r2r", "serve"]
