#!/bin/bash

# Release System Installation Script
# Usage: curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash
# Usage with version: curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash -s -- --version v1.0.0

set -e

# Default values
VERSION="master"
BRANCH="master"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --version)
            VERSION="$2"
            BRANCH="v$2"
            shift 2
            ;;
        --help)
            echo "Release System Installer"
            echo ""
            echo "Usage:"
            echo "  curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash"
            echo "  curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash -s -- --version v1.0.0"
            echo ""
            echo "Options:"
            echo "  --version VERSION    Install specific version (e.g., v1.0.0)"
            echo "  --help              Show this help message"
            echo ""
            echo "Examples:"
            echo "  # Install latest version"
            echo "  curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash"
            echo ""
            echo "  # Install specific version"
            echo "  curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash -s -- --version v1.0.0"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo "🚀 Installing Release System..."
echo "================================"
echo "Version: $VERSION"
echo ""

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
if [ "$VERSION" = "master" ]; then
    SETUP_URL="https://raw.githubusercontent.com/toolkit-development/release-system/master/setup.sh"
else
    SETUP_URL="https://raw.githubusercontent.com/toolkit-development/release-system/$BRANCH/setup.sh"
fi

if ! curl -fsSL "$SETUP_URL" -o "$TEMP_DIR/setup.sh"; then
    echo "❌ Error: Failed to download release system version $VERSION"
    echo "Please check if the version exists: https://github.com/toolkit-development/release-system/releases"
    exit 1
fi

# Make it executable and run it
chmod +x "$TEMP_DIR/setup.sh"
"$TEMP_DIR/setup.sh"

# Cleanup
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Installation complete!"
echo "Version installed: $VERSION"
echo "Run 'make help' to see available commands" 