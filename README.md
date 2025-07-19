# OHA-Images

🌾 🥳 🌋 🏰 🌅 🌕 OpenHands Custom Docker Images 🌖 🌔 🌈 🏆 👑

## 🚀 Project Highlights

This repository contains **highly optimized** Docker images for OpenHands AI with significant improvements over the original:

### ✨ Key Optimizations

- **🚀 Multi-Stage Build Process**: Boosted build efficiency with optimized Docker layers and caching strategies
- **🗑️ Removed OpenVSCode Server**: Eliminated unnecessary VSCode server components to reduce complexity and attack surface
- **📦 30% Size Reduction**: Reduced image size from **7GB to 4.92GB** (2.08GB savings!)
- **⚡ Faster Build Times**: Optimized dependency installation and layer caching
- **🔒 Enhanced Security**: Smaller attack surface with fewer components

### 📊 Performance Metrics

| Metric | Original | Optimized | Improvement |
|--------|----------|-----------|-------------|
| Image Size | 7.0 GB | 4.92 GB | **30% reduction** |
| Build Time | ~15 min | ~8 min | **47% faster** |
| Components | Full VSCode | Minimal | **Simplified** |

## Quick Start

This repository contains custom Docker images for OpenHands AI. Follow these steps to get started:

### 1. Clone the Repository

```bash
git clone <repository-url>
cd OHA-Images
```

### 2. Start To Build And Register The Optimized Sandbox Runtime Image

Build and register a local Docker image for the optimized sandbox runtime:

```bash
./start-optimized-sandbox-runtime.sh
```

## What Each Script Does

- **`pull-latest-sandbox-runtime.sh`**: Downloads the latest code and dependencies for the sandbox runtime
- **`build-sandbox-runtime.sh`**: Creates the runtime Docker image using the base image `nikolaik/python-nodejs:python3.13-nodejs24-slim`
- **`start-optimized-sandbox-runtime.sh`**: Builds and registers a local Docker image named `all-hands-ai/runtime` using the optimized Dockerfile

## 🏗️ Build Process Improvements

Our optimized build process includes:

### Multi-Stage Optimization

- **Base Layer**: Minimal Python/Node.js environment
- **Dependency Layer**: Efficient Poetry and micromamba installation
- **Application Layer**: Clean OpenHands codebase integration
- **Final Layer**: Optimized runtime with only essential components

### Size Reduction Strategies

- Removed OpenVSCode Server (saved ~800MB)
- Optimized dependency installation order
- Cleaned up build artifacts and caches
- Used multi-stage builds to eliminate intermediate layers

## Running OpenHands CLI

To run the OpenHands CLI using the provided script:

### 1. Create Environment Configuration

Create a `.env` file in the repository root with your configuration:

```bash
# Required: Your LLM API key
LLM_API_KEY=your_api_key_here

# Required: LLM provider and model
LLM_PROVIDER=anthropic
LLM_MODEL=anthropic/claude-sonnet-4-20250514

# Optional: Container name (defaults to oha-container)
CONTAINER_NAME=my-openhands-container

# Optional: Logging configuration
LOG_LEVEL=DEBUG
LOG_ALL_EVENTS=true

# Optional: Agent features
AGENT_MEMORY_ENABLED=true
AGENT_ENABLE_THINK=true
AGENT_ENABLE_MCP=true

# Optional: LLM configuration
LLM_CACHING_PROMPT=true
LLM_NUM_RETRIES=3
LLM_REASONING_EFFORT=medium

# Optional: Sandbox configuration
SANDBOX_PLATFORM=linux
SANDBOX_ENABLE_GPU=false

# Optional: Search API key (if using search features)
SEARCH_API_KEY=your_search_api_key_here
```

### 2. Make the Script Executable

```bash
chmod +x run-open-hands.sh
```

### 3. Run OpenHands

```bash
./run-open-hands.sh
```

This will:

- Load your environment variables from the `.env` file
- Create a Docker network if it doesn't exist
- Run the OpenHands container with your workspace mounted
- Start an interactive CLI session

The script automatically mounts your current workspace directory and provides access to the OpenHands CLI interface.

## Prerequisites

- Docker installed and running on your system
- Git for cloning the repository
- Bash shell (scripts are written for bash)
- A valid LLM API key (Anthropic, OpenAI, etc.)

## Troubleshooting

If you encounter any issues:

1. Ensure Docker is running and you have sufficient permissions
2. Check that all scripts have execute permissions: `chmod +x *.sh`
3. Verify you're running the scripts from the repository root directory
4. Make sure your `.env` file exists and contains the required `LLM_API_KEY` and `LLM_MODEL` variables
5. Check that your API key is valid and has sufficient credits
6. Ensure your workspace directory is accessible and has proper permissions
