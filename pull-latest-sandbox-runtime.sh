#!/bin/bash
set -eo pipefail

# This script updates all git submodules to their latest versions.
# It assumes it is being run from the root of the project directory.

# 1. Initialize and sync submodules
# Ensures that all submodules are initialized and checked out to the commit
# specified in the parent repository. The --recursive flag handles nested submodules.
echo "INFO: Initializing and syncing submodules..."
git submodule update --init --recursive

# 2. Update submodules to the latest commit from their remote branch
# The --remote flag fetches the latest changes from the submodule's remote repository.
# It updates the submodule to the tip of its configured upstream branch.
# The --merge flag merges the fetched changes into the submodule's working tree.
echo "INFO: Pulling the latest remote changes for all submodules..."
git submodule update --remote --merge

echo "INFO: All submodules have been updated to their latest versions."
