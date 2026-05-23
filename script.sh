#!/bin/bash
set -e

PATTERN="${INPUT_PATH:-**/*.js}"
MAX_SIZE="${INPUT_MAX_SIZE:-100000}"
FAIL_ON_ERROR="${INPUT_FAIL_ON_ERROR:-true}"

echo "::group::File Size Check"
echo "Pattern: $PATTERN"
echo "Max size: $MAX_SIZE bytes"
echo "================================"

# Enable globstar for ** patterns
shopt -s globstar nullglob

FILES=($PATTERN)
EXCEEDED=0
TOTAL=0

for file in "${FILES[@]}"; do
  if [ -f "$file" ]; then
    TOTAL=$((TOTAL + 1))
    SIZE=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null || echo 0)
    if [ "$SIZE" -gt "$MAX_SIZE" ]; then
      echo "❌ $file — ${SIZE} bytes (limit: ${MAX_SIZE})"
      EXCEEDED=$((EXCEEDED + 1))
    else
      echo "✅ $file — ${SIZE} bytes"
    fi
  fi
done

echo "================================"
echo "Total files checked: $TOTAL"
echo "Files exceeding limit: $EXCEEDED"
echo "::endgroup::"

# Set outputs
echo "total-checked=$TOTAL" >> "$GITHUB_OUTPUT"
echo "files-exceeded=$EXCEEDED" >> "$GITHUB_OUTPUT"

if [ "$EXCEEDED" -gt 0 ] && [ "$FAIL_ON_ERROR" = "true" ]; then
  echo "::error:: $EXCEEDED file(s) exceed the size limit of $MAX_SIZE bytes"
  exit 1
fi
