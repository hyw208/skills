#!/bin/bash
set -e

# Ensure the script is run from the skill's directory
cd "$(dirname "$0")"

echo "Setting up environment and running tests..." >&2

# Create virtual environment with uv if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..." >&2
    uv venv
fi

# Activate the virtual environment
source .venv/bin/activate

# Install test dependencies and the skill in editable mode
echo "Installing/updating test dependencies..." >&2
uv pip install -e ".[test]"

# Run pytest, passing along any arguments
pytest "$@"
