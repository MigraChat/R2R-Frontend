OSE # Use an official Python base image
FROM python:3.10-slim

# Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PATH="/root/.local/bin:$PATH"

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
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

# Clone R2R repository (use a specific release or commit for reproducibility)
RUN git clone --depth 1 https://github.com/SciPhi-AI/R2R.git /app/R2R

# Install R2R dependencies using Poetry
WORKDIR /app/R2R/py
RUN poetry install -E "core ingestion-bundle" --no-dev

# Expose a port if needed
EXPOSE 8000
EXPOSE 7272

# Add a command to run your application
CMD ["poetry", "run", "r2r", "serve"]
