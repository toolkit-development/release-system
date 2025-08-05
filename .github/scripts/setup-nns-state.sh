#!/bin/bash

# Setup NNS state for testing
# This script creates a local NNS state that can be used with PocketIC tests

set -e

# Get the absolute path to the project root
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
TARGET_DIR="$PROJECT_ROOT/src/test_helper"

# Detect if running in CI environment
if [ -n "$CI" ] || [ -n "$GITHUB_ACTIONS" ]; then
    echo "🏗️ Detected CI environment, using CI-optimized settings..."
    CI_MODE=true
else
    echo "💻 Running in local environment..."
    CI_MODE=false
fi

echo "🚀 Setting up NNS state for testing..."
echo "📁 The NNS state will be saved to: $TARGET_DIR/nns_state"

# Check if dfx is installed
if ! command -v dfx &> /dev/null; then
    echo "❌ dfx is not installed. Please install dfx first:"
    echo "   sh -ci \"\$(curl -fsSL https://internetcomputer.org/install.sh)\""
    exit 1
fi

# Check if required tools are installed
if ! command -v jq &> /dev/null; then
    echo "📦 Installing jq..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install jq
    else
        sudo apt update && sudo apt install -y jq
    fi
fi

if ! command -v protoc &> /dev/null; then
    echo "📦 Installing protobuf compiler..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install protobuf
    else
        sudo apt update && sudo apt install -y protobuf-compiler
    fi
fi

# Create temporary directory for NNS setup
TEMP_DIR=$(mktemp -d)
echo "📁 Using temporary directory: $TEMP_DIR"

# Change to temporary directory
cd "$TEMP_DIR"

# Create new dfx project for NNS
echo "📋 Creating NNS project..."
dfx new --no-frontend --type motoko nns_state
cd nns_state

# Update dfx.json to add local network configuration with proper subnet setup
echo "⚙️ Configuring dfx.json..."
cat > dfx.json << 'EOF'
{
  "canisters": {
    "nns_state": {
      "type": "motoko",
      "main": "src/nns_state/main.mo"
    }
  },
  "networks": {
    "local": {
      "bind": "127.0.0.1:8080",
      "type": "ephemeral",
      "replica": {
        "subnet_type": "system",
        "subnet_config": {
          "subnet_kind": "NNS",
          "canister_ranges": [
            {
              "start": "rwlgt-iiaaa-aaaaa-aaaaa-cai",
              "end": "renrk-eyaaa-aaaaa-aaada-cai"
            },
            {
              "start": "qoctq-giaaa-aaaaa-aaaea-cai", 
              "end": "n5n4y-3aaaa-aaaaa-p777q-cai"
            }
          ]
        }
      }
    }
  },
  "version": 1
}
EOF

# Stop dfx if running
echo "🛑 Stopping dfx if running..."
dfx stop 2>/dev/null || true

# Start dfx with clean network
echo "🚀 Starting dfx with clean network..."
dfx start --background --clean --artificial-delay 0

# Wait for dfx to be ready (longer timeout for CI)
echo "⏳ Waiting for dfx to be ready..."
sleep 20

# Install NNS extension
echo "📦 Installing NNS extension..."
dfx extension install nns

# Setup NNS with longer timeout for CI environment
echo "🔧 Setting up NNS (this may take several minutes)..."
echo "📋 This step can take 5-10 minutes in CI environments..."

# Retry logic for CI environments
MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    echo "🔄 Attempt $((RETRY_COUNT + 1)) of $MAX_RETRIES..."
    
    if dfx extension run nns install; then
        echo "✅ NNS setup completed successfully!"
        break
    else
        RETRY_COUNT=$((RETRY_COUNT + 1))
        if [ $RETRY_COUNT -lt $MAX_RETRIES ]; then
            echo "❌ NNS setup failed, retrying in 30 seconds..."
            sleep 30
        else
            echo "❌ NNS setup failed after $MAX_RETRIES attempts"
            exit 1
        fi
    fi
done

# Wait for NNS setup to complete (longer timeout for CI)
echo "⏳ Waiting for NNS setup to complete..."
sleep 60

# Verify NNS setup and configure subnet if needed
echo "🔍 Verifying NNS setup..."
dfx extension run nns subnet list || echo "No subnets found, this is normal for initial setup"

# Get the NNS state path
NNS_STATE_PATH="$(pwd)/.dfx/network/local/state/replicated_state"
echo "📁 NNS state path: $NNS_STATE_PATH"

# Wait for checkpoint to be created (with longer timeout for CI)
echo "⏳ Waiting for checkpoint to be created..."
TIMEOUT=30  # 0.5 minute timeout for CI
echo "📋 This process will run for up to ${TIMEOUT} seconds to build the NNS state..."
ELAPSED=0
while [ ! -d "$NNS_STATE_PATH/node-100/state/checkpoints" ] || [ -z "$(ls -A "$NNS_STATE_PATH/node-100/state/checkpoints" 2>/dev/null)" ]; do
    if [ $ELAPSED -ge $TIMEOUT ]; then
        echo "⏰ Timeout reached after ${TIMEOUT}s, proceeding with available state"
        break
    fi
    
    # Print progress message every 5 seconds
    if [ $((ELAPSED % 5)) -eq 0 ]; then
        echo "🔄 NNS state build in progress... (${ELAPSED}s elapsed, timeout: ${TIMEOUT}s)"
    fi
    
    sleep 5
    ELAPSED=$((ELAPSED + 5))
done

echo "✅ Checkpoint created, stopping dfx..."
# Stop dfx immediately after checkpoint is confirmed
dfx stop

# Find NNS subnet ID from topology.json
echo "🔍 Finding NNS subnet from topology.json..."
TOPOLOGY_FILE="$NNS_STATE_PATH/topology.json"
if [ ! -f "$TOPOLOGY_FILE" ]; then
    echo "❌ topology.json not found at $TOPOLOGY_FILE"
    exit 1
fi

# Use hardcoded NNS subnet key
echo "🔍 Using hardcoded NNS subnet key..."
NNS_SUBNET_KEY="f3e0a9711469429c3d961cd911fea7495e3919476b8d5de66cba203f05d9a734"
echo "✅ Using hardcoded NNS subnet key: $NNS_SUBNET_KEY"


# Create target directory
echo "📁 Creating target directory: $TARGET_DIR"

# Copy only the NNS subnet state contents directly
echo "📋 Copying NNS subnet state..."
mkdir -p "$TARGET_DIR/nns_state"
cp -r "$NNS_STATE_PATH/$NNS_SUBNET_KEY"/* "$TARGET_DIR/nns_state/"

# Create compressed archive
echo "🗜️ Creating compressed archive..."
cd "$TARGET_DIR"
tar -zcvf nns_state.tar.gz nns_state/

# Clean up temporary files
echo "🧹 Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

echo "✅ NNS state setup completed!"
echo ""
echo "📋 Configuration:"
echo "  - State path: $TARGET_DIR/nns_state/node-100/state"
echo "  - Archive: $TARGET_DIR/nns_state.tar.gz"
echo ""
echo "📝 NNS state is ready for testing!" 