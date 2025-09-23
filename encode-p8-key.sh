#!/bin/bash

# Script to properly encode .p8 key for GitHub secrets
# Usage: ./encode-p8-key.sh path/to/AuthKey_XXXXXX.p8

if [ $# -eq 0 ]; then
    echo "Usage: $0 path/to/AuthKey_XXXXXX.p8"
    exit 1
fi

P8_FILE="$1"

if [ ! -f "$P8_FILE" ]; then
    echo "Error: File $P8_FILE not found"
    exit 1
fi

echo "Encoding $P8_FILE to base64..."
echo ""

# Method 1: Create base64 string without any newlines
BASE64_CONTENT=$(cat "$P8_FILE" | base64 | tr -d '\n')

echo "✅ Base64 encoded successfully!"
echo ""
echo "Length: $(echo -n "$BASE64_CONTENT" | wc -c) characters"
echo ""
echo "First 20 chars: $(echo -n "$BASE64_CONTENT" | head -c 20)..."
echo "Last 20 chars: ...$(echo -n "$BASE64_CONTENT" | tail -c 20)"
echo ""
echo "==============================================="
echo "Copy the following content to your GitHub secret APP_STORE_CONNECT_API_KEY_BASE64:"
echo "==============================================="
echo ""
echo "$BASE64_CONTENT"
echo ""
echo "==============================================="
echo ""
echo "To set this in GitHub:"
echo "1. Go to Settings > Secrets and variables > Actions"
echo "2. Edit APP_STORE_CONNECT_API_KEY_BASE64"
echo "3. Paste the entire base64 string above (everything between the lines)"
echo "4. Save the secret"