import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), ".."))

from extraction.parser import parse_ingredient_list


def test_ingredients_label_stripped():
    result = parse_ingredient_list("INGREDIENTS: Sugar, Salt, Wheat Flour")
    assert result == ["Sugar", "Salt", "Wheat Flour"], result


def test_ingredients_label_lowercase_stripped():
    result = parse_ingredient_list("Ingredients : Sugar, Salt")
    assert result == ["Sugar", "Salt"], result


if __name__ == "__main__":
    test_ingredients_label_stripped()
    test_ingredients_label_lowercase_stripped()
    print("PASS: both label-stripping tests")
