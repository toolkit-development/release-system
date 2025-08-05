cargo test candid -p user_registry

cargo build -p user_registry --release --target wasm32-unknown-unknown

gzip -c target/wasm32-unknown-unknown/release/user_registry.wasm > target/wasm32-unknown-unknown/release/user_registry.wasm.gz

cp target/wasm32-unknown-unknown/release/user_registry.wasm.gz wasm/user_registry.wasm.gz
