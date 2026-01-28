import jsonschema
import json
import os

def load_schema():
    schema_path = os.path.join(os.path.dirname(__file__), '../contracts/calculator_schema.json')
    with open(schema_path, 'r') as f:
        return json.load(f)

def calculate(data):
    """
    Performs basic calculation (add/subtract).
    Validates input against calculator_schema.json.
    """
    schema = load_schema()
    try:
        jsonschema.validate(instance=data, schema=schema)
    except jsonschema.exceptions.ValidationError as e:
        raise ValueError(f"Validation failed: {e.message}")

    a = data["a"]
    b = data["b"]
    operation = data["operation"]

    if operation == "add":
        return a + b
    elif operation == "subtract":
        return a - b
    
    # Should be caught by schema validation, but for safety:
    raise ValueError(f"Unknown operation: {operation}")
