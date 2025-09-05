#!/bin/bash
set -e

echo "🧪 Running unit tests..."
pytest tests/
echo "✅ Tests passed!"
