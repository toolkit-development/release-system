#!/bin/bash

# Extract NNS state for testing
# This script extracts the compressed NNS state for use in tests

set -e

NNS_STATE_DIR="src/test_helper/nns_state"
ARCHIVE_PATH="src/test_helper/nns_state.tar.gz"

echo "📋 Extracting NNS state for testing..."

# Check if archive exists
if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "❌ NNS state archive not found at $ARCHIVE_PATH"
    echo "Please run ./scripts/setup-nns-state.sh first to create the NNS state."
    exit 1
fi

# Create directory if it doesn't exist
mkdir -p "$NNS_STATE_DIR"

# Extract the archive
echo "🗜️ Extracting NNS state archive..."
cd "$NNS_STATE_DIR"
tar -xzf ../nns_state.tar.gz --strip-components=1

# Check if extraction was successful
if [ -d "checkpoints" ] && [ -d "tip" ]; then
    echo "✅ NNS state extracted successfully!"
    echo "📁 State available at: $NNS_STATE_DIR"
    
    # Load configuration if available
    if [ -f "nns_config.json" ]; then
        echo "📋 Configuration loaded:"
        cat nns_config.json | jq .
    fi
else
    echo "❌ Failed to extract NNS state"
    exit 1
fi 