# GitHub Copilot CLI Sandbox

A dev container for experimenting with GitHub Copilot, AI-assisted coding, and REST APIs — with a full polyglot toolchain pre-installed.

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) running on your machine
- [VS Code](https://code.visualstudio.com/) with the [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed

---

## Getting started

1. **Clone the repo**
   ```bash
   git clone https://github.com/lybekkc/github_copilot.git
   cd github_copilot
   ```

2. **Open in VS Code**
   ```bash
   code .
   ```

3. **Start the dev container**
   When prompted *"Reopen in Container"*, click it — or use:
   `Cmd/Ctrl+Shift+P` → **Dev Containers: Reopen in Container**

   First build takes a few minutes (downloads the image and installs all tools).
   Subsequent starts are fast.

4. **Authenticate with GitHub Copilot**
   Open a terminal inside the container and run:
   ```bash
   copilot
   ```
   Follow the device-login flow in your browser.

---

## What's inside

| Tool | Purpose |
|------|---------|
| **GitHub Copilot CLI** | AI assistant in the terminal |
| **OpenCode** | Alternative AI coding CLI |
| **GitLab CLI (`glab`)** | GitLab operations from the terminal |
| **GitHub CLI (`gh`)** | GitHub operations from the terminal |
| **Rust** | Systems programming (stable toolchain via rustup) |
| **Java 21** | JVM — Temurin distribution |
| **Maven** | Java build tool |
| **Gradle** | Java/Kotlin build tool |
| **Kotlin** | JVM language (compiler + REPL) |
| **Python 3** | Scripting and AI/ML work |
| **UV** | Fast Python package & project manager |
| **Node.js 24** | JavaScript / TypeScript runtime |
| **kubectl** | Kubernetes CLI |
| **Docker CE** | Build and run containers (Docker-in-Docker) |
| **psql** | PostgreSQL client |
| **git** | Version control |
| **jq** | JSON processing in the terminal |

---

## Workspace layout

```
/workspaces/
  sandbox/            ← VS Code opens here (your working directory)
  github_copilot/     ← the repo, mounted from your Mac
```

Your sandbox files live only inside the container. The repo itself (`github_copilot/`) is mounted from your host machine — changes there are saved to disk.

---

## Common tasks

### Python projects (UV)
```bash
# Create a new project
uv init my-project && cd my-project

# Add dependencies
uv add requests pandas

# Run a script
uv run main.py

# Update UV itself
uv self update
```

### Rust
```bash
cargo new my-app && cd my-app
cargo run
cargo test
rustup update   # upgrade Rust toolchain
```

### Kotlin
```bash
# REPL
kotlinc

# Compile and run a file
kotlinc hello.kt -include-runtime -d hello.jar
java -jar hello.jar
```

### Java / Maven / Gradle
```bash
mvn archetype:generate   # new Maven project
gradle init              # new Gradle project
```

### Docker (inside the container)
```bash
docker build -t my-image .
docker run --rm my-image
docker compose up
```

### PostgreSQL client
```bash
psql -h <host> -U <user> -d <database>
```

### kubectl
```bash
kubectl config get-contexts
kubectl get pods -n <namespace>
```

---

## Upgrading tools

| Tool | How to upgrade |
|------|---------------|
| Java, Maven, Gradle, Rust, kubectl, Docker, gh | Change `"version"` in `.devcontainer/devcontainer.json`, then rebuild |
| Kotlin | Change `KOTLIN_VERSION` in `.devcontainer/setup.sh`, then rebuild |
| UV | `uv self update` (or rebuild — always fetches latest) |
| Node.js | Change base image tag in `.devcontainer/Dockerfile`, then rebuild |
| psql | Follows system apt — `sudo apt upgrade` |

**Rebuild the container:**
`Cmd/Ctrl+Shift+P` → **Dev Containers: Rebuild Container**

To also clear the Docker cache:
`Cmd/Ctrl+Shift+P` → **Dev Containers: Rebuild Container Without Cache**

---

## Quitting the dev container

| Action | Command |
|--------|---------|
| Close connection, keep container running | `Cmd/Ctrl+Shift+P` → **Close Remote Connection** |
| Return to local VS Code (stops container) | `Cmd/Ctrl+Shift+P` → **Reopen Folder Locally** |
| Stop container from terminal | `docker ps` then `docker stop <id>` |

---

## Copilot cloud agent setup

The file `.github/workflows/copilot-setup-steps.yml` pre-installs the same toolchain in the **GitHub Copilot cloud agent** environment, so Copilot has access to all the tools above when working on tasks in this repo.

The workflow also runs automatically on every push/PR that modifies it, so you can verify it works via the **Actions** tab on GitHub.

---

## Troubleshooting

### `/workspaces/sandbox` is not writable
Fixed in the Dockerfile — the directory is now created and owned by the `node` user at build time. If you still hit this, do a full rebuild:
`Cmd/Ctrl+Shift+P` → **Dev Containers: Rebuild Container Without Cache**

### Private repo — authentication required
The devcontainer forwards two things from your Mac automatically:

- **`~/.gitconfig`** — mounted read-only, so your git identity and any credential helpers carry over
- **SSH agent** — the macOS SSH agent socket is forwarded via `SSH_AUTH_SOCK`

For SSH to work, make sure your key is loaded on the host before opening the container:
```bash
ssh-add ~/.ssh/id_ed25519   # or id_rsa
ssh-add -l                  # verify it's loaded
```

For HTTPS private repos, authenticate `gh` inside the container once:
```bash
gh auth login
gh auth setup-git   # configures git to use gh as credential helper
```

---



The sandbox is isolated — the AI cannot read or modify files on your Mac outside of the mounted project folder. Rebuild the container at any time to get a clean slate.

