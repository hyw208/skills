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
            "message": "Usage: ./run_skill.sh '<expression>'"
        }))
        sys.exit(1)
    print(calculate(sys.argv[1]))