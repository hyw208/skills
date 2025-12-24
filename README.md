# Tutorial: Creating Reusable, Standalone Skills for AI Assistants

This tutorial guides you through creating custom skills (tools or scripts) that AI assistants like GitHub Copilot and Gemini CLI can use. We'll focus on creating robust, Python-based skills with isolated environments that are easy to manage and share.

## Where to Store Skills: Scope and Discovery

The location of your skills determines their scope and how they are discovered by you or an AI assistant.

1.  **Project-Specific Skills**:
    *   **Location**: `.github/skills/your_skill/`
    *   **Scope**: Available only within that specific project.
    *   **Use Case**: Ideal for skills that are tightly coupled to a project's domain, codebase, or dependencies (e.g., a script to run project-specific tests or deployments).

2.  **Global (User-Level) Skills**:
    *   **Location**: `~/skills/your_skill/`
    *   **Scope**: Available to you across all projects.
    *   **Use Case**: Perfect for general-purpose utilities that you use everywhere, like code formatters, file converters, or a universal calculator.

3.  **Team or Organizational Skills (Advanced)**:
    *   **Location**: A shared repository (e.g., `git clone https://github.com/my-org/skills.git ~/org-skills`).
    *   **Scope**: Available to everyone who clones the repository.
    *   **Use Case**: For standardizing tooling and automation across a team or organization. The AI assistant might need to be configured to look in the `~/org-skills` directory.

## Step 1: Set Up the Skill Structure

For this tutorial, we'll create a project-specific calculator skill.

-   **Create the directory**: `mkdir -p .github/skills/calculator`
-   **Required Files**:
    -   `skill.py`: The main Python script.
    -   `skill.md`: Documentation for the skill.
    -   `pyproject.toml`: Project metadata and dependencies.
    -   `skill.sh`: A robust runner script.

## Step 2: Write the Skill Script

This script contains the core logic of the skill.

**`.github/skills/calculator/skill.py`**
```python
#!/usr/bin/env python3
import sys
import json

def calculate(expression: str) -> str:
    """
    Safely evaluates a mathematical expression and returns a JSON string.
    """
    try:
        # Using a restricted and safe evaluation context is critical.
        # For a real-world application, a dedicated parsing library
        # like 'asteval' or 'numexpr' is strongly recommended over eval().
        allowed_names = {"__builtins__": {}}
        result = eval(expression, allowed_names, {})
        # Format output as JSON for easy parsing by AI assistants
        return json.dumps({"status": "success", "result": result})
    except Exception as e:
        # Return a structured error
        return json.dumps({"status": "error", "message": str(e)})

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(json.dumps({
            "status": "error",
            "message": "Usage: ./skill.sh '<expression>'"
        }))
        sys.exit(1)
    print(calculate(sys.argv[1]))
```

## Step 3: Define Dependencies

Use `pyproject.toml` to manage dependencies. `uv` is a fast, modern tool for this.

**`.github/skills/calculator/pyproject.toml`**
```toml
[project]
name = "calculator-skill"
version = "0.1.0"
description = "A simple calculator skill."
dependencies = [
  # For a safer evaluator, you might add:
  # "asteval"
]
```

## Step 4: Create a Robust Runner Script

This script sets up the environment and executes the skill, ensuring reliability.

**`.github/skills/calculator/skill.sh`**
```bash
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
```

## Step 5: Document the Skill in `skill.md`

Good documentation is key for you and the AI to understand how to use the skill.

**`.github/skills/calculator/skill.md`**
```markdown
# Calculator Skill

Safely evaluates a mathematical expression.

## Usage

```bash
./skill.sh "2+3*4"
```

## Input
A single string containing a mathematical expression.

## Output
A JSON object with `status` and `result` or `message`.

### Success Example
```json
{"status": "success", "result": 14}
```

### Error Example
```json
{"status": "error", "message": "unsupported operand type(s) for +: 'int' and 'str'"}
```

## Step 6: Test and Use the Skill

From within the `.github/skills/calculator` directory:
```bash
chmod +x skill.sh
./skill.sh "10 / 2"
# Expected Output: {"status": "success", "result": 5.0}
```

## Best Practices for High-Quality Skills

1.  **Structured Output (JSON)**: Always return structured data like JSON. It's far easier for an AI assistant to parse reliably than plain text. Include a `status` field (`success` or `error`).

2.  **Explicit Testing**: Write unit tests for your `skill.py`.
    *   Create a `tests/` directory.
    *   Use a framework like `pytest`.
    *   Example (`tests/test_skill.py`):
        ```python
        import json
        from skill import calculate

        def test_calculate_success():
            result = json.loads(calculate("2+2"))
            assert result["status"] == "success"
            assert result["result"] == 4
        ```

3.  **Security is Paramount**:
    *   **Never trust input**. Sanitize and validate all arguments.
    *   **Avoid `eval()`**. Use safer alternatives like `asteval` or write a specific parser for your expected input.
    *   **Limit permissions**. The skill script should have the minimum necessary permissions to perform its task.

4.  **Version Control**:
    *   Add `.venv/` and `__pycache__/` to your project's `.gitignore` file to avoid committing environment-specific files.

By following these guidelines, you can create powerful, safe, and reusable skills that significantly enhance the capabilities of your AI assistant.

## Testing Skills

This project uses `pytest` for testing skills. Test dependencies are defined under `[project.optional-dependencies.test]` in each skill's `pyproject.toml` file.

To run the tests for a specific skill (e.g., the `calculator` skill), use the `test.sh` script:

1.  **Navigate to the skill's directory:**
    ```bash
    cd .github/skills/calculator
    ```

2.  **Run the test script:**
    ```bash
    ./test.sh
    ```
    You can also pass arguments directly to `pytest` via the script:
    ```bash
    ./test.sh -k "success"
    ```