#!/bin/bash

# Simple one-liner installation script
# Usage: curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash

set -e

echo "🚀 Installing Release System..."
echo "================================"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from within a git repository."
    exit 1
fi

# Create temporary directory
TEMP_DIR="/tmp/release-system-$(date +%s)"
mkdir -p "$TEMP_DIR"

# Download the main setup script
echo "📥 Downloading release system..."
curl -fsSL "https://raw.githubusercontent.com/toolkit-development/release-system/master/setup.sh" -o "$TEMP_DIR/setup.sh"

# Make it executable and run it
chmod +x "$TEMP_DIR/setup.sh"
"$TEMP_DIR/setup.sh"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Installation complete!"
echo "Run 'make help' to see available commands" 