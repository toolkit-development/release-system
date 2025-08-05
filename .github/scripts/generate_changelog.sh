#!/bin/bash

# Generate changelog from git commits and pull requests
# Usage: ./scripts/generate_changelog.sh [version] [previous_version]

set -e

VERSION=${1:-$(grep '^version = ' src/user_registry/Cargo.toml | cut -d'"' -f2)}
PREVIOUS_VERSION=${2:-$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")}

# Remove 'v' prefix from previous version for comparison
PREVIOUS_VERSION_CLEAN=${PREVIOUS_VERSION#v}

echo "Generating changelog for version $VERSION (since $PREVIOUS_VERSION)"

# Create temporary files
TEMP_CHANGELOG=$(mktemp)
TEMP_COMMITS=$(mktemp)

# Get commits since the previous version, with fallback for non-existent tags
if git rev-parse "$PREVIOUS_VERSION" >/dev/null 2>&1; then
    echo "📋 Found tag $PREVIOUS_VERSION, getting commits since then..."
    git log --pretty=format:"%H|%s|%an|%ad" --date=short "${PREVIOUS_VERSION}..HEAD" > "$TEMP_COMMITS"
else
    echo "⚠️ Tag $PREVIOUS_VERSION not found, getting all commits..."
    git log --pretty=format:"%H|%s|%an|%ad" --date=short > "$TEMP_COMMITS"
fi

# Initialize changelog sections
echo "# Changelog" > "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"
echo "All notable changes to this project will be documented in this file." >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"
echo "The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)," >> "$TEMP_CHANGELOG"
echo "and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html)." >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Add current version section
echo "## [$VERSION] - $(date +%Y-%m-%d)" >> "$TEMP_CHANGELOG"
echo "" >> "$TEMP_CHANGELOG"

# Initialize change categories
ADDED=()
CHANGED=()
DEPRECATED=()
REMOVED=()
FIXED=()
SECURITY=()

# Process commits and categorize them
while IFS='|' read -r hash message author date; do
    # Skip merge commits and version bumps
    if [[ "$message" =~ ^Merge|^Bump|^Release ]]; then
        continue
    fi
    
    # Categorize based on conventional commit format
    if [[ "$message" =~ ^feat: ]]; then
        ADDED+=("${message#feat: }")
    elif [[ "$message" =~ ^fix: ]]; then
        FIXED+=("${message#fix: }")
    elif [[ "$message" =~ ^BREAKING\ CHANGE: ]]; then
        REMOVED+=("${message#BREAKING CHANGE: }")
    elif [[ "$message" =~ ^security: ]]; then
        SECURITY+=("${message#security: }")
    elif [[ "$message" =~ ^refactor:|^perf:|^style: ]]; then
        CHANGED+=("${message}")
    elif [[ "$message" =~ ^docs: ]]; then
        # Skip documentation changes for now
        continue
    else
        # Default to changed for unrecognized formats
        CHANGED+=("$message")
    fi
done < "$TEMP_COMMITS"

# Add sections to changelog
if [ ${#ADDED[@]} -gt 0 ]; then
    echo "### Added" >> "$TEMP_CHANGELOG"
    for item in "${ADDED[@]}"; do
        echo "- $item" >> "$TEMP_CHANGELOG"
    done
    echo "" >> "$TEMP_CHANGELOG"
fi

if [ ${#CHANGED[@]} -gt 0 ]; then
    echo "### Changed" >> "$TEMP_CHANGELOG"
    for item in "${CHANGED[@]}"; do
        echo "- $item" >> "$TEMP_CHANGELOG"
    done
    echo "" >> "$TEMP_CHANGELOG"
fi

if [ ${#FIXED[@]} -gt 0 ]; then
    echo "### Fixed" >> "$TEMP_CHANGELOG"
    for item in "${FIXED[@]}"; do
        echo "- $item" >> "$TEMP_CHANGELOG"
    done
    echo "" >> "$TEMP_CHANGELOG"
fi

if [ ${#SECURITY[@]} -gt 0 ]; then
    echo "### Security" >> "$TEMP_CHANGELOG"
    for item in "${SECURITY[@]}"; do
        echo "- $item" >> "$TEMP_CHANGELOG"
    done
    echo "" >> "$TEMP_CHANGELOG"
fi

if [ ${#REMOVED[@]} -gt 0 ]; then
    echo "### Removed" >> "$TEMP_CHANGELOG"
    for item in "${REMOVED[@]}"; do
        echo "- $item" >> "$TEMP_CHANGELOG"
    done
    echo "" >> "$TEMP_CHANGELOG"
fi

if [ ${#DEPRECATED[@]} -gt 0 ]; then
    echo "### Deprecated" >> "$TEMP_CHANGELOG"
    for item in "${DEPRECATED[@]}"; do
        echo "- $item" >> "$TEMP_CHANGELOG"
    done
    echo "" >> "$TEMP_CHANGELOG"
fi

# If no changes found, add a note
if [ ${#ADDED[@]} -eq 0 ] && [ ${#CHANGED[@]} -eq 0 ] && [ ${#FIXED[@]} -eq 0 ] && [ ${#SECURITY[@]} -eq 0 ] && [ ${#REMOVED[@]} -eq 0 ] && [ ${#DEPRECATED[@]} -eq 0 ]; then
    echo "### Maintenance" >> "$TEMP_CHANGELOG"
    echo "- No user-facing changes in this release" >> "$TEMP_CHANGELOG"
    echo "" >> "$TEMP_CHANGELOG"
fi

# Add previous changelog content if it exists
if [ -f "CHANGELOG.md" ]; then
    echo "" >> "$TEMP_CHANGELOG"
    echo "---" >> "$TEMP_CHANGELOG"
    echo "" >> "$TEMP_CHANGELOG"
    # Skip the header and add the rest
    tail -n +15 CHANGELOG.md >> "$TEMP_CHANGELOG" 2>/dev/null || true
fi

# Replace the existing changelog
mv "$TEMP_CHANGELOG" "CHANGELOG.md"

# Clean up
rm -f "$TEMP_COMMITS"

echo "✅ Changelog generated for version $VERSION"
echo "📝 Review CHANGELOG.md and commit if satisfied" 