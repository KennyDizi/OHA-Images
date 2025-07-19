#!/bin/bash
set -eo pipefail

# This script builds the runtime sandbox Docker image.
# It assumes that it is being run from the root of the project directory.

echo "INFO: Preparing Docker build context..."

# 1. Define Docker image name and build context path
IMAGE_NAME="all-hands-ai/runtime"
CONTEXT_PATH="containers/runtime"
RELEASE_TAG="latest"
DOCKER_FILE_NAME="Dockerfile-optimized"

# 2. Build the Docker image
# The -f flag specifies the Dockerfile-optimized location.
# The last argument specifies the build context path.
echo "INFO: Building Docker image: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" -f "${CONTEXT_PATH}/${DOCKER_FILE_NAME}" "${CONTEXT_PATH}"

echo "INFO: Docker image ${IMAGE_NAME}:${RELEASE_TAG} has been built successfully."
