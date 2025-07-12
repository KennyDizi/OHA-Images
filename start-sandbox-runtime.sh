#!/bin/bash
set -eo pipefail

# This script builds the runtime sandbox Docker image.
# It assumes that it is being run from the root of the project directory.

# 1. Prepare Docker build context
# The `build-sandbox-runtime.sh` script creates the `containers/runtime` directory
# and populates it with the necessary files (source code, Dockerfile, etc.).
echo "INFO: Preparing Docker build context..."
./build-sandbox-runtime.sh

# 2. Define Docker image name and build context path
IMAGE_NAME="all-hands-ai/runtime"
CONTEXT_PATH="containers/runtime"

# 3. Build the Docker image
# The -f flag specifies the Dockerfile location.
# The last argument specifies the build context path.
echo "INFO: Building Docker image: ${IMAGE_NAME}"
docker build -t "${IMAGE_NAME}" -f "${CONTEXT_PATH}/Dockerfile" "${CONTEXT_PATH}"

echo "INFO: Docker image ${IMAGE_NAME} built successfully."
