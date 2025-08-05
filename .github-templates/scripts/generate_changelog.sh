#!/bin/bash

# Generate changelog content from git commits
VERSION=${1:-$(grep '^version = ' src/YOUR_CANISTER/Cargo.toml | cut -d'"' -f2)}

echo "Generating changelog for version $VERSION..."

# Generate changelog content
echo "### Changes" >> CHANGELOG.md
git log --oneline --no-merges $(git describe --tags --abbrev=0 2>/dev/null || echo "")..HEAD | cut -d' ' -f2- | sed 's/^/- /' >> CHANGELOG.md

echo "✅ Changelog generated for version $VERSION" 