#!/bin/bash

# Create checksums for release assets
echo "Creating checksums for release assets..."

# Create checksums
sha256sum wasm/YOUR_CANISTER.wasm.gz > wasm/YOUR_CANISTER.wasm.gz.sha256
sha256sum src/YOUR_CANISTER/YOUR_CANISTER.did > YOUR_CANISTER.did.sha256
sha256sum canister_ids.json > canister_ids.json.sha256

# Create combined checksum file
echo "Combined checksums:" > checksums.txt
echo "" >> checksums.txt
echo "YOUR_CANISTER.wasm.gz:" >> checksums.txt
cat wasm/YOUR_CANISTER.wasm.gz.sha256 >> checksums.txt
echo "" >> checksums.txt
echo "YOUR_CANISTER.did:" >> checksums.txt
cat YOUR_CANISTER.did.sha256 >> checksums.txt
echo "" >> checksums.txt
echo "canister_ids.json:" >> checksums.txt
cat canister_ids.json.sha256 >> checksums.txt

echo "✅ Checksums created successfully" 