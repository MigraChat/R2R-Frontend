# Use an official Python base image
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

# Clone the repository with the last 10 commits for a buffer
RUN git clone --depth 10 https://github.com/SciPhi-AI/R2R.git /app/R2R && \
    cd /app/R2R && \
    # Ensure the desired fallback commit is checked out
    git checkout 17a34e6

# Install R2R dependencies using Poetry
WORKDIR /app/R2R/py
RUN poetry install -E "core ingestion-bundle" --no-dev

# Expose a port if needed
EXPOSE 8000
EXPOSE 7272

# Add a command to run your application
CMD ["poetry", "run", "r2r", "serve"]
