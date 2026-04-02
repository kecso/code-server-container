# Custom code-server: Python, Node, Cursor Agent CLI.
FROM lscr.io/linuxserver/code-server:latest

USER root

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    nodejs \
    npm \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
 && npm install -g nodemon \
 && rm -rf /var/lib/apt/lists/*

# Service runs as `abc` with HOME=/config (see linuxserver svc-code-server run script).
RUN mkdir -p /config && chown -R abc:abc /config

USER abc
ENV HOME=/config
WORKDIR /config/workspace

# Cursor Agent CLI install
RUN curl -fsSL https://cursor.com/install | bash

ENV PATH="/config/.local/bin:${PATH}"
