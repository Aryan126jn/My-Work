import json
import random

fortunes = [
    "🚀 Today’s a great day to learn Terraform.",
    "🐍 Python Lambda says hi, Aryan!",
    "💡 Jenkins will behave today (maybe).",
    "🔥 AWS bills shrink when you IaC.",
    "☁️ Cloud is just someone else’s computer."
]

#fortunes = [
#    "🤖 AI is learning faster than ever!",
#    "📱 Your smartphone might be smarter than you think.",
#    "💾 Data is the new gold in the digital age."
#]
def lambda_handler(event=None, context=None):
    """Simulates AWS Lambda handler returning a random fortune."""
    fortune = random.choice(fortunes)
    return {
        "statusCode": 200,
        "body": fortune
    }

if __name__ == "__main__":
    # When run directly (e.g. inside Docker), just print a fortune
    result = lambda_handler()
    print(result["body"])
