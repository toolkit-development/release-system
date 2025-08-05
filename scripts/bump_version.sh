#!/bin/bash

# Version bumping script for Cargo.toml files
# Usage: ./scripts/bump_version.sh [patch|minor|major]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Function to get current version from Cargo.toml
get_current_version() {
    local cargo_file="$1"
    if [ -f "$cargo_file" ]; then
        grep '^version = ' "$cargo_file" | cut -d'"' -f2
    else
        print_error "Cargo.toml not found at $cargo_file"
        exit 1
    fi
}

# Function to calculate new version
calculate_new_version() {
    local current_version="$1"
    local bump_type="$2"
    
    local major=$(echo "$current_version" | cut -d. -f1)
    local minor=$(echo "$current_version" | cut -d. -f2)
    local patch=$(echo "$current_version" | cut -d. -f3)
    
    case "$bump_type" in
        "patch")
            echo "$major.$minor.$((patch + 1))"
            ;;
        "minor")
            echo "$major.$((minor + 1)).0"
            ;;
        "major")
            echo "$((major + 1)).0.0"
            ;;
        *)
            print_error "Invalid bump type: $bump_type. Use patch, minor, or major."
            exit 1
            ;;
    esac
}

# Function to update version in Cargo.toml
update_version() {
    local cargo_file="$1"
    local new_version="$2"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i.bak "s/^version = \".*\"/version = \"$new_version\"/" "$cargo_file"
        rm "${cargo_file}.bak"
    else
        # Linux
        sed -i "s/^version = \".*\"/version = \"$new_version\"/" "$cargo_file"
    fi
}

# Main script logic
main() {
    local bump_type="$1"
    
    if [ -z "$bump_type" ]; then
        print_error "Usage: $0 [patch|minor|major]"
        exit 1
    fi
    
    print_info "Starting version bump process..."
    
    # Try to find Cargo.toml in different locations
    local cargo_files=()
    
    # Check for workspace Cargo.toml
    if [ -f "Cargo.toml" ]; then
        cargo_files+=("Cargo.toml")
    fi
    
    # Check for package Cargo.toml in common locations
    for dir in src/*/; do
        if [ -d "$dir" ] && [ -f "${dir}Cargo.toml" ]; then
            cargo_files+=("${dir}Cargo.toml")
        fi
    done
    
    if [ ${#cargo_files[@]} -eq 0 ]; then
        print_error "No Cargo.toml files found in the project"
        exit 1
    fi
    
    print_info "Found ${#cargo_files[@]} Cargo.toml file(s):"
    for file in "${cargo_files[@]}"; do
        echo "  - $file"
    done
    
    # Process each Cargo.toml file
    for cargo_file in "${cargo_files[@]}"; do
        print_info "Processing $cargo_file..."
        
        local current_version=$(get_current_version "$cargo_file")
        local new_version=$(calculate_new_version "$current_version" "$bump_type")
        
        print_info "Current version: $current_version"
        print_info "New version: $new_version"
        
        # Update the version
        update_version "$cargo_file" "$new_version"
        
        print_success "Updated $cargo_file from $current_version to $new_version"
    done
    
    print_success "Version bump completed successfully!"
    print_info "Don't forget to:"
    echo "  1. Review the changes"
    echo "  2. Commit the version updates"
    echo "  3. Create a release tag"
    echo "  4. Update CHANGELOG.md"
}

# Run the main function with all arguments
main "$@" 