# Use an official Python base image
FROM python:3.10-slim

# Set environment variables to prevent Python from writing pyc files and to force stdout/stderr to be unbuffered
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install pipx and its dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    && python -m pip install --upgrade pip setuptools \
    && python -m pip install pipx \
    && pipx ensurepath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry using pipx
RUN pipx install poetry

# Set pipx's binary directory to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set work directory
WORKDIR /app

# Clone R2R repository and install dependencies
RUN git clone https://github.com/SciPhi-AI/R2R.git /app/R2R

# Install R2R dependencies using Poetry
WORKDIR /app/R2R/py
RUN poetry install -E "core ingestion-bundle"

# Set the entrypoint
CMD ["bash"]
