import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from extraction.parser import parse_ingredient_list


def test_simple_comma_split():
    result = parse_ingredient_list("Sugar, Salt, Wheat Flour")
    assert result == ["Sugar", "Salt", "Wheat Flour"]


def test_nested_parentheses_not_split():
    result = parse_ingredient_list("Wheat Flour (Wheat, Gluten), Sugar, Salt")
    assert result == ["Wheat Flour (Wheat, Gluten)", "Sugar", "Salt"]


def test_trailing_period_removed():
    result = parse_ingredient_list("Sugar, Salt.")
    assert result == ["Sugar", "Salt"]


def test_semicolon_separator():
    result = parse_ingredient_list("Palm Oil; Sugar; Salt")
    assert result == ["Palm Oil", "Sugar", "Salt"]


def test_leading_and_stripped():
    result = parse_ingredient_list("Sugar, Salt, and Citric Acid")
    assert result == ["Sugar", "Salt", "Citric Acid"]


def test_empty_input():
    assert parse_ingredient_list("") == []
    assert parse_ingredient_list("   ") == []


def test_extra_whitespace_normalized():
    result = parse_ingredient_list("Sugar,   Salt,\nWheat   Flour")
    assert result == ["Sugar", "Salt", "Wheat Flour"]


def test_multiple_nested_groups():
    result = parse_ingredient_list(
        "Refined Wheat Flour (Maida), Sugar, Palm Oil, Milk Solids (Milk, Milk Fat), Salt"
    )
    assert result == [
        "Refined Wheat Flour (Maida)",
        "Sugar",
        "Palm Oil",
        "Milk Solids (Milk, Milk Fat)",
        "Salt",
    ]


if __name__ == "__main__":
    import inspect

    tests = [
        obj for name, obj in list(globals().items())
        if name.startswith("test_") and inspect.isfunction(obj)
    ]
    passed, failed = 0, 0
    for t in tests:
        try:
            t()
            print(f"PASS: {t.__name__}")
            passed += 1
        except AssertionError as e:
            print(f"FAIL: {t.__name__} -> {e}")
            failed += 1
    print(f"\n{passed} passed, {failed} failed")
