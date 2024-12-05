# Use an official Python 3.12 base image
FROM python:3.12-slim

# Set environment variables to optimize Python
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies including curl, git, and Node.js prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    build-essential \
    libpq-dev \
    ca-certificates \
    && apt-get clean

# Install Python dependencies
RUN python -m pip install --upgrade pip setuptools \
    && python -m pip install pipx \
    && pipx ensurepath

# Install R2R CLI with additional dependencies
RUN pipx install 'r2r[core,ingestion-bundle]'

# Clone the R2R repositories
RUN git clone --depth 1 --branch v3.2.30 https://github.com/SciPhi-AI/R2R.git /workspaces/R2R-Frontend/R2R
RUN git clone --depth 1 https://github.com/SciPhi-AI/R2R-Application.git /workspaces/R2R-Frontend/R2R-Application

# Install Node.js (LTS) and pnpm
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g pnpm
WORKDIR /workspaces/R2R-Frontend/R2R-Application

# Ensure pnpm is updated and usable
RUN pnpm update
# RUN pnpm env use --global lts

# Install and build the frontend application
RUN pnpm install
RUN pnpm build

# Expose application ports
EXPOSE 3000
EXPOSE 7272

# Set default command to r2r serve and pnpm start
CMD ["sh", "-c", "r2r serve & pnpm start"]
