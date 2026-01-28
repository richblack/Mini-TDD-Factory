import sys
import os
import pytest

# Add actions to path so we can import modules
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from actions.calculate import calculate

def test_add():
    result = calculate({"a": 10, "b": 5, "operation": "add"})
    assert result == 15

def test_subtract():
    result = calculate({"a": 10, "b": 5, "operation": "subtract"})
    assert result == 5

def test_invalid_operation():
    with pytest.raises(ValueError, match="Validation failed"):
        calculate({"a": 10, "b": 5, "operation": "multiply"})

def test_missing_field():
    with pytest.raises(ValueError, match="Validation failed"):
        calculate({"a": 10, "operation": "add"})

def test_invalid_type():
    with pytest.raises(ValueError, match="Validation failed"):
        calculate({"a": "ten", "b": 5, "operation": "add"})
