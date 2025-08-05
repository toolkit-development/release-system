#!/bin/bash

cargo test candid -p YOUR_CANISTER
cargo build -p YOUR_CANISTER --release --target wasm32-unknown-unknown
gzip -c target/wasm32-unknown-unknown/release/YOUR_CANISTER.wasm > target/wasm32-unknown-unknown/release/YOUR_CANISTER.wasm.gz
mkdir -p wasm
cp target/wasm32-unknown-unknown/release/YOUR_CANISTER.wasm.gz wasm/YOUR_CANISTER.wasm.gz
