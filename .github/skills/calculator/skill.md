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
```

