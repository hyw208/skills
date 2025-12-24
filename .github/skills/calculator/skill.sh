#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Ensure the script is run from the skill's directory
cd "$(dirname "$0")"

echo "Running calculator skill..." >&2

# Create virtual environment with uv if it doesn't exist
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..." >&2
    uv venv
fi

# Activate the virtual environment
source .venv/bin/activate

# Install dependencies if pyproject.toml has changed
# (A simple timestamp check for demonstration)
if [ "pyproject.toml" -nt ".venv/pip-self-check.json" ] 2>/dev/null; then
    echo "Installing/updating dependencies..." >&2
    uv pip install -e .
fi

# Execute the skill with the provided argument
python skill.py "$1"