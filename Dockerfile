# Use an official Python 3.12 base image
FROM python:3.12-slim

# Set environment variables to optimize Python and Node.js
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
ENV PATH="/root/.local/bin:/root/.npm-global/bin:$PATH"

# Install system dependencies including Node.js, npm, and pnpm
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    libpq-dev \
    ca-certificates \
    && apt-get clean

# Install Node.js (LTS version) and npm
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && apt-get clean

# Install pnpm globally
RUN npm install -g pnpm

# Verify installations
RUN node --version \
    && npm --version \
    && pnpm --version

# Set pnpm to use the Node.js LTS version globally
RUN pnpm env use --global lts

# Install Python dependencies
RUN python -m pip install --upgrade pip setuptools \
    && python -m pip install pipx \
    && pipx ensurepath

# Install R2R CLI with additional dependencies
RUN pipx install 'r2r[core,ingestion-bundle]'

# Set the working directory for the app
WORKDIR /app

# Clone the R2R repositories
RUN git clone --depth 1 --branch v3.2.30 https://github.com/SciPhi-AI/R2R.git /app/R2R
RUN git clone --depth 1 https://github.com/SciPhi-AI/R2R-Application.git /app/R2R-Application

# Install and build the frontend application
WORKDIR /app/R2R-Application
RUN pnpm install
RUN pnpm build
RUN pnpm start

# Expose application ports
EXPOSE 3000
EXPOSE 7272

# Set the default command to run the application
CMD ["r2r", "serve"]
