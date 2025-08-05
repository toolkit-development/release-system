#!/bin/bash

# Create combined checksums file for releases
# Usage: bash .github/scripts/create_checksums.sh <version>

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
    echo "❌ Error: Version parameter is required"
    echo "Usage: bash .github/scripts/create_checksums.sh <version>"
    exit 1
fi

echo "🔍 Generating checksums for version $VERSION..."

# Generate individual checksums
sha256sum wasm/user_registry.wasm.gz > wasm/user_registry.wasm.gz.sha256
sha256sum user_registry.did > user_registry.did.sha256
sha256sum canister_ids.json > canister_ids.json.sha256

# Create combined checksums file
echo "Checksums for version $VERSION:" > checksums.txt
echo "==========================================" >> checksums.txt
echo "" >> checksums.txt
echo "user_registry.wasm.gz:" >> checksums.txt
cat wasm/user_registry.wasm.gz.sha256 >> checksums.txt
echo "" >> checksums.txt
echo "user_registry.did:" >> checksums.txt
cat user_registry.did.sha256 >> checksums.txt
echo "" >> checksums.txt
echo "canister_ids.json:" >> checksums.txt
cat canister_ids.json.sha256 >> checksums.txt

echo "✅ Checksums generated for version $VERSION"
echo "✅ Combined checksums file created: checksums.txt" 