import unittest
import json
from src.app import lambda_handler

class TestFortuneHandler(unittest.TestCase):
    def test_handler_returns_valid_fortune(self):
        response = lambda_handler()
        self.assertEqual(response["statusCode"], 200)

        # Parse the body from JSON
        fortune = json.loads(response["body"])
        valid_fortunes = [
            "🚀 Today’s a great day to learn Terraform.",
            "🐍 Python Lambda says hi, Aryan!",
            "💡 Jenkins will behave today (maybe).",
            "🔥 AWS bills shrink when you IaC.",
            "☁️ Cloud is just someone else’s computer."
        ]
        self.assertIn(fortune, valid_fortunes)

if __name__ == "__main__":
    unittest.main()
