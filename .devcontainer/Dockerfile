FROM mcr.microsoft.com/devcontainers/javascript-node:24-bookworm

# Core tools + Python + PostgreSQL client
RUN apt-get update && apt-get install -y --no-install-recommends \
      jq \
      curl \
      git \
      python3 \
      python3-pip \
      python3-venv \
      postgresql-client \
      gnome-keyring \
      dbus-x11 \
      unzip \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install --break-system-packages secretstorage

# UV — fast Python package & project manager (replaces pip for project work)
# To upgrade: uv self update   |   or rebuild container (always fetches latest)
RUN curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local sh

# GitLab CLI (glab)
RUN curl -fsSL "https://gitlab.com/gitlab-org/cli/-/releases/v1.92.1/downloads/glab_1.92.1_linux_amd64.tar.gz" \
    | tar -xz -C /usr/local/bin --strip-components=1 bin/glab

# GitHub Copilot CLI (offisiell npm-pakke)
RUN npm install -g @github/copilot

# OpenCode CLI
RUN npm install -g opencode-ai

USER node
WORKDIR /workspaces/sandbox
