# Custom code-server for linux/amd64 Debian server
FROM lscr.io/linuxserver/code-server:latest

USER root

# 1. Install prerequisites
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    nodejs \
    npm \
    python3 \
    python3-dev \
    python3-pip \
    python3-venv \
 && npm install -g nodemon

# 2. Add Docker's official GPG key and APT repository (download.docker.com, not docker.com)
RUN mkdir -p /etc/apt/keyrings \
 && . /etc/os-release \
 && curl -fsSL "https://download.docker.com/linux/${ID}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
 && chmod a+r /etc/apt/keyrings/docker.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${ID} $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Install only the Docker CLI
RUN apt-get update && apt-get install -y docker-ce-cli \
 && rm -rf /var/lib/apt/lists/*

# 3b. docker.sock: set host docker GID at runtime (defaults to 999). In Portainer / compose:
#     environment:
#       DOCKER_GID: "989"   # host: getent group docker | cut -d: -f3
COPY scripts/docker-gid-init /custom-cont-init.d/99-docker-gid
RUN chmod +x /custom-cont-init.d/99-docker-gid

# 4. Install Cursor Agent
RUN curl -fsSL https://cursor.com/install | bash

# 5. Ensure the PATH is correct for the 'abc' user
ENV PATH="/config/.local/bin:${PATH}"

# 6. Git over SSH with passphrase: run `setup-git-ssh` once per container start; new bash
#    sessions load ~/.ssh/agent.env automatically until restart.
COPY scripts/setup-git-ssh /usr/local/bin/setup-git-ssh
COPY scripts/99-git-ssh-agent.sh /etc/profile.d/99-git-ssh-agent.sh
RUN chmod +x /usr/local/bin/setup-git-ssh \
 && chmod 644 /etc/profile.d/99-git-ssh-agent.sh \
 && printf '\n# Load ssh-agent env for Git (see setup-git-ssh)\n' >> /etc/bash.bashrc \
 && printf 'if [ -f /etc/profile.d/99-git-ssh-agent.sh ]; then . /etc/profile.d/99-git-ssh-agent.sh; fi\n' >> /etc/bash.bashrc
