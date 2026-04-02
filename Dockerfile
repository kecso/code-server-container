# Custom code-server for linux/amd64 Debian server
FROM lscr.io/linuxserver/code-server:latest

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    nodejs \
    npm \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
    docker.io \
 && npm install -g nodemon \
 # Download and install official Docker CLI binary
 && curl -fsSL https://docker.com | tar xvz -C /tmp/ \
 && mv /tmp/docker/docker /usr/local/bin/docker \
 && rm -rf /tmp/docker \
 && rm -rf /var/lib/apt/lists/*

# Install Cursor Agent
RUN curl -fsSL https://cursor.com/install | bash

ENV PATH="/config/.local/bin:${PATH}"
