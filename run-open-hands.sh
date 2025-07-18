#!/bin/bash

# Check if .env file exists
if [ -f .env ]; then
    # Load environment variables from .env file
    export $(cat .env | grep -v '^#' | xargs)

    # ---------- guarantee a deterministic container name ----------
    : "${CONTAINER_NAME:=oha-container}"   # default if .env omits it
    # ----------------------------------------------------------------

    # Only pass LLM_REASONING_EFFORT to Docker if it is set/non-empty
    LLM_REASONING_EFFORT_ARG=""
    if [[ -n "$LLM_REASONING_EFFORT" ]]; then
        LLM_REASONING_EFFORT_ARG="-e LLM_REASONING_EFFORT=${LLM_REASONING_EFFORT}"
    fi

    # Set default LOG_LEVEL if not specified, then pass to Docker
    : "${LOG_LEVEL:=DEBUG}"
    LOG_LEVEL_ARG="-e LOG_LEVEL=${LOG_LEVEL}"

    # Set default LOG_ALL_EVENTS if not specified, then pass to Docker
    : "${LOG_ALL_EVENTS:=true}"
    LOG_ALL_EVENTS_ARG="-e LOG_ALL_EVENTS=${LOG_ALL_EVENTS}"

    # Set default SANDBOX_RUNTIME_CONTAINER_IMAGE if not specified, then pass to Docker
    : "${SANDBOX_RUNTIME_CONTAINER_IMAGE:="all-hands-ai/runtime:latest"}"
    SANDBOX_RUNTIME_CONTAINER_IMAGE_ARG="-e SANDBOX_RUNTIME_CONTAINER_IMAGE=${SANDBOX_RUNTIME_CONTAINER_IMAGE}"

    # Display selected model & reasoning-effort (only when an effort was supplied)
    if [[ -n "$LLM_REASONING_EFFORT_ARG" ]]; then
        echo "Using model: ${LLM_MODEL} with reasoning effort: ${LLM_REASONING_EFFORT}"
    fi

    export HOST_WORKSPACE="$(pwd)"
    export SANDBOX_VOLUMES="${HOST_WORKSPACE}:/workspace:rw"
    export RUNTIME_MOUNT="${HOST_WORKSPACE}:/workspace:rw"
    export WORKSPACE_MOUNT_PATH_IN_SANDBOX="${HOST_WORKSPACE}:/workspace:rw"

    # ------------------------------------------------------------------
    # Ensure the dedicated Docker network exists
    if ! docker network ls --format '{{.Name}}' | grep -q '^oha-cli-network$'; then
        echo "Creating Docker network 'oha-cli-network'"
        docker network create oha-cli-network
    fi
    # ------------------------------------------------------------------

    # Print out environment variables that are passed to docker
    echo "--- Passing the following environment variables to Docker ---"
    print_var() {
        local name="$1"
        local value="$2"
        if [ -z "$value" ]; then return; fi
        # Convert name to lowercase for case-insensitive check, using tr for portability
        local lower_name
        lower_name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
        # Check for sensitive keywords in the variable name
        if [[ "$lower_name" == *key* || "$lower_name" == *secret* ]]; then
            echo "${name}=${value:0:6}***"
        else
            echo "${name}=${value}"
        fi
    }
    print_var "SANDBOX_RUNTIME_CONTAINER_IMAGE" "$SANDBOX_RUNTIME_CONTAINER_IMAGE"
    print_var "SANDBOX_USER_ID" "$(id -u)"
    print_var "SANDBOX_VOLUMES" "$SANDBOX_VOLUMES"
    print_var "RUNTIME_MOUNT" "$RUNTIME_MOUNT"
    print_var "WORKSPACE_MOUNT_PATH_IN_SANDBOX" "$WORKSPACE_MOUNT_PATH_IN_SANDBOX"
    print_var "LLM_API_KEY" "$LLM_API_KEY"
    print_var "LLM_PROVIDER" "$LLM_PROVIDER"
    print_var "LLM_MODEL" "$LLM_MODEL"
    print_var "AGENT_MEMORY_ENABLED" "$AGENT_MEMORY_ENABLED"
    print_var "LLM_CACHING_PROMPT" "$LLM_CACHING_PROMPT"
    print_var "AGENT_ENABLE_THINK" "$AGENT_ENABLE_THINK"
    print_var "LLM_NUM_RETRIES" "$LLM_NUM_RETRIES"
    print_var "AGENT_ENABLE_MCP" "$AGENT_ENABLE_MCP"
    print_var "LLM_REASONING_EFFORT" "$LLM_REASONING_EFFORT"
    print_var "LOG_LEVEL" "$LOG_LEVEL"
    print_var "LOG_ALL_EVENTS" "$LOG_ALL_EVENTS"
    print_var "SANDBOX_PLATFORM" "$SANDBOX_PLATFORM"
    print_var "SANDBOX_ENABLE_GPU" "$SANDBOX_ENABLE_GPU"
    print_var "SEARCH_API_KEY" "$SEARCH_API_KEY"
    echo "-----------------------------------------------------------"

    # Run the Open Hands container
    docker run -it --rm --pull=always \
        $SANDBOX_RUNTIME_CONTAINER_IMAGE_ARG \
        -e SANDBOX_USER_ID=$(id -u) \
        -e SANDBOX_VOLUMES=$SANDBOX_VOLUMES \
        -e RUNTIME_MOUNT=$RUNTIME_MOUNT \
        -e WORKSPACE_MOUNT_PATH_IN_SANDBOX=$WORKSPACE_MOUNT_PATH_IN_SANDBOX \
        -e LLM_API_KEY=$LLM_API_KEY \
        -e LLM_PROVIDER=$LLM_PROVIDER \
        -e LLM_MODEL=$LLM_MODEL \
        -e AGENT_MEMORY_ENABLED=$AGENT_MEMORY_ENABLED \
        -e LLM_CACHING_PROMPT=$LLM_CACHING_PROMPT \
        -e AGENT_ENABLE_THINK=$AGENT_ENABLE_THINK \
        -e LLM_NUM_RETRIES=$LLM_NUM_RETRIES \
        -e AGENT_ENABLE_MCP=$AGENT_ENABLE_MCP \
        $LLM_REASONING_EFFORT_ARG \
        $LOG_ALL_EVENTS_ARG \
        $LOG_LEVEL_ARG \
        -e SANDBOX_PLATFORM=$SANDBOX_PLATFORM \
        -e SANDBOX_ENABLE_GPU=$SANDBOX_ENABLE_GPU \
        -e SEARCH_API_KEY=$SEARCH_API_KEY \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v ~/.openhands:/.openhands \
        -v "${HOST_WORKSPACE}:/workspace:rw" \
        -w /workspace \
        -p 3080:3080 \
        --add-host host.docker.internal:host-gateway \
        --network oha-cli-network \
        --name "${CONTAINER_NAME}" \
        docker.all-hands.dev/all-hands-ai/openhands:0.49.1 \
        python3 -m openhands.cli.main --override-cli-mode true
else
    echo "Error: .env file not found"
    exit 1
fi
