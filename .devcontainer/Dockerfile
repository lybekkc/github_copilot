FROM mcr.microsoft.com/devcontainers/javascript-node:24-bookworm

# Nyttige verktøy for vibe coding mot REST API-er
RUN apt-get update && apt-get install -y --no-install-recommends \
      jq \
      curl \
      python3 \
      python3-pip \
      python3-venv \
      gnome-keyring \
      dbus-x11 \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --break-system-packages secretstorage

# GitLab CLI (glab)
RUN curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v1.92.1/downloads/glab_1.92.1_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 bin/glab

# GitHub Copilot CLI (offisiell npm-pakke)
RUN npm install -g @github/copilot

# OpenCode CLI
RUN npm install -g opencode-ai

USER node
WORKDIR /workspaces/sandbox
