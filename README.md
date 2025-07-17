# OHA-Images

🌾 🥳 🌋 🏰 🌅 🌕 OpenHands Custom Docker Images 🌖 🌔 🌈 🏆 👑

## Quick Start

This repository contains custom Docker images for OpenHands AI. Follow these steps to get started:

### 1. Clone the Repository

```bash
git clone <repository-url>
cd OHA-Images
```

### 2. Pull the Latest Sandbox Runtime

Pull the latest code and dependencies:

```bash
./pull-latest-sandbox-runtime.sh
```

### 3. Build the Runtime Docker Image

Build the runtime sandbox Docker image:

```bash
./build-sandbox-runtime.sh
```

### 4. Start the Optimized Sandbox Runtime

Build and register a local Docker image for the optimized sandbox runtime:

```bash
./start-optimized-sandbox-runtime.sh
```

## What Each Script Does

- **`pull-latest-sandbox-runtime.sh`**: Downloads the latest code and dependencies for the sandbox runtime
- **`build-sandbox-runtime.sh`**: Creates the runtime Docker image using the base image `nikolaik/python-nodejs:python3.13-nodejs24-slim`
- **`start-optimized-sandbox-runtime.sh`**: Builds and registers a local Docker image named `all-hands-ai/runtime` using the optimized Dockerfile

## Prerequisites

- Docker installed and running on your system
- Git for cloning the repository
- Bash shell (scripts are written for bash)

## Troubleshooting

If you encounter any issues:

1. Ensure Docker is running and you have sufficient permissions
2. Check that all scripts have execute permissions: `chmod +x *.sh`
3. Verify you're running the scripts from the repository root directory
