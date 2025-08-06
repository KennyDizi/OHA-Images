FROM nikolaik/python-nodejs:python3.13-nodejs24-slim

# Shared environment variables
ENV POETRY_VIRTUALENVS_PATH=/openhands/poetry \
    MAMBA_ROOT_PREFIX=/openhands/micromamba \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    EDITOR=code \
    VISUAL=code \
    GIT_EDITOR="code --wait" \
    OPENVSCODE_SERVER_ROOT=/openhands/.openvscode-server










# ================================================================
# START: Build Runtime Image from Scratch
# ================================================================
# This is used in cases where the base image is something more generic like nikolaik/python-nodejs
# rather than the current OpenHands release



# Install base system dependencies




RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget curl ca-certificates sudo apt-utils git jq tmux build-essential ripgrep ffmpeg \
        libgl1-mesa-glx \
        libasound2-plugins libatomic1 \
        # Install Docker dependencies
        apt-transport-https ca-certificates curl gnupg lsb-release




# Install uv (required by MCP)
RUN curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/openhands/bin" sh
# Add /openhands/bin to PATH
ENV PATH="/openhands/bin:${PATH}"

# Remove UID 1000 named pn or ubuntu, so the 'openhands' user can be created from ubuntu hosts
RUN (if getent passwd 1000 | grep -q pn; then userdel pn; fi) && \
    (if getent passwd 1000 | grep -q ubuntu; then userdel ubuntu; fi)


# Create necessary directories
RUN mkdir -p /openhands && \
    mkdir -p /openhands/logs && \
    mkdir -p /openhands/poetry


# ================================================================
# Install Docker following official documentation
# https://docs.docker.com/engine/install/ubuntu/
# https://docs.docker.com/engine/install/debian/
RUN \
    # Determine OS type and install accordingly
    if [[ "nikolaik/python-nodejs:python3.13-nodejs24-slim" == *"ubuntu"* ]] || [[ "nikolaik/python-nodejs:python3.13-nodejs24-slim" == *"mswebench"* ]]; then \
        # Handle Ubuntu (following https://docs.docker.com/engine/install/ubuntu/)
        # Add Docker's official GPG key
        apt-get update && \
        apt-get install -y ca-certificates curl && \
        install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc && \
        chmod a+r /etc/apt/keyrings/docker.asc && \
        # Add the repository to Apt sources
        # For Ubuntu 24.04 (noble), use jammy repository as noble isn't supported yet
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
    else \
        # Handle Debian (following https://docs.docker.com/engine/install/debian/)
        # Add Docker's official GPG key
        apt-get update && \
        apt-get install -y ca-certificates curl && \
        install -m 0755 -d /etc/apt/keyrings && \
        curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc && \
        chmod a+r /etc/apt/keyrings/docker.asc && \
        # Add the repository to Apt sources
        # For Debian, if it's noble (testing/unstable), use bookworm (stable) repository
        if [ "$(lsb_release -cs)" = "noble" ]; then \
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian bookworm stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
        else \
            echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null; \
        fi; \
    fi && \
    # Install Docker Engine, containerd, and Docker Compose
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Configure Docker daemon with MTU 1450 to prevent packet fragmentation issues
RUN mkdir -p /etc/docker && \
    echo '{"mtu": 1450}' > /etc/docker/daemon.json
# ================================================================



# Install micromamba
RUN mkdir -p /openhands/micromamba/bin && \
    /bin/bash -c "PREFIX_LOCATION=/openhands/micromamba BIN_FOLDER=/openhands/micromamba/bin INIT_YES=no CONDA_FORGE_YES=yes $(curl -L https://micro.mamba.pm/install.sh)" && \
    /openhands/micromamba/bin/micromamba config remove channels defaults && \
    /openhands/micromamba/bin/micromamba config list

# Create the openhands virtual environment and install poetry and python
RUN /openhands/micromamba/bin/micromamba create -n openhands -y && \
    /openhands/micromamba/bin/micromamba install -n openhands -c conda-forge poetry python=3.13 -y

# Create a clean openhands directory including only the pyproject.toml, poetry.lock and openhands/__init__.py
RUN \
    if [ -d /openhands/code ]; then rm -rf /openhands/code; fi && \
    mkdir -p /openhands/code/openhands && \
    touch /openhands/code/openhands/__init__.py && \
    # Set global git configuration to ensure proper author/committer information
    git config --global user.name "openhands" && \
    git config --global user.email "openhands@all-hands.dev"

COPY ./code/pyproject.toml ./code/poetry.lock /openhands/code/


# Install all dependencies
WORKDIR /openhands/code

RUN \
    /openhands/micromamba/bin/micromamba config set changeps1 False && \
    /openhands/micromamba/bin/micromamba run -n openhands poetry config virtualenvs.path /openhands/poetry && \
    /openhands/micromamba/bin/micromamba run -n openhands poetry env use python3.13 && \
    # Install project dependencies
    /openhands/micromamba/bin/micromamba run -n openhands poetry install --only main,runtime --no-interaction --no-root && \
    # Update and install additional tools
    # (There used to be an "apt-get update" here, hopefully we can skip it.)
    
    /openhands/micromamba/bin/micromamba run -n openhands poetry run playwright install --with-deps chromium && \
    
    # Set environment variables
    /openhands/micromamba/bin/micromamba run -n openhands poetry run python -c "import sys; print('OH_INTERPRETER_PATH=' + sys.executable)" >> /etc/environment && \
    # Set permissions
    chmod -R g+rws /openhands/poetry && \
    mkdir -p /openhands/workspace && chmod -R g+rws,o+rw /openhands/workspace && \
    # Clean up
    /openhands/micromamba/bin/micromamba run -n openhands poetry cache clear --all . -n && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    /openhands/micromamba/bin/micromamba clean --all



# ================================================================
# END: Build Runtime Image from Scratch
# ================================================================



# Reference:
# 1. https://github.com/gitpod-io/openvscode-server
# 2. https://github.com/gitpod-io/openvscode-releases

# Setup VSCode Server
ARG RELEASE_TAG="openvscode-server-v1.98.2"
ARG RELEASE_ORG="gitpod-io"
# ARG USERNAME=openvscode-server
# ARG USER_UID=1000
# ARG USER_GID=1000

RUN if [ -z "${RELEASE_TAG}" ]; then \
        echo "The RELEASE_TAG build arg must be set." >&2 && \
        exit 1; \
    fi && \
    arch=$(uname -m) && \
    if [ "${arch}" = "x86_64" ]; then \
        arch="x64"; \
    elif [ "${arch}" = "aarch64" ]; then \
        arch="arm64"; \
    elif [ "${arch}" = "armv7l" ]; then \
        arch="armhf"; \
    fi && \
    wget https://github.com/${RELEASE_ORG}/openvscode-server/releases/download/${RELEASE_TAG}/${RELEASE_TAG}-linux-${arch}.tar.gz && \
    tar -xzf ${RELEASE_TAG}-linux-${arch}.tar.gz && \
    if [ -d "${OPENVSCODE_SERVER_ROOT}" ]; then rm -rf "${OPENVSCODE_SERVER_ROOT}"; fi && \
    mv ${RELEASE_TAG}-linux-${arch} ${OPENVSCODE_SERVER_ROOT} && \
    cp ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/openvscode-server ${OPENVSCODE_SERVER_ROOT}/bin/remote-cli/code && \
    rm -f ${RELEASE_TAG}-linux-${arch}.tar.gz





# ================================================================
# Copy Project source files
# ================================================================
RUN if [ -d /openhands/code/openhands ]; then rm -rf /openhands/code/openhands; fi
COPY ./code/pyproject.toml ./code/poetry.lock /openhands/code/

COPY ./code/openhands /openhands/code/openhands
RUN chmod a+rwx /openhands/code/openhands/__init__.py



# ================================================================
# END: Build from versioned image
# ================================================================


# Install extra dependencies if specified
