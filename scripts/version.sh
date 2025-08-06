#!/bin/bash

# Version management script for release-system
# Usage: ./scripts/version.sh [bump-patch|bump-minor|bump-major|show|set VERSION]

set -e

VERSION_FILE="VERSION"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Get current version
get_current_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"
    fi
}

# Calculate new version
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

# Update version file
update_version() {
    local new_version="$1"
    echo "$new_version" > "$VERSION_FILE"
    print_success "Version updated to $new_version"
}

# Show current version
show_version() {
    local current_version=$(get_current_version)
    echo "Current version: $current_version"
}

# Main script logic
main() {
    local action="$1"
    local version="$2"
    
    case "$action" in
        "bump-patch")
            local current_version=$(get_current_version)
            local new_version=$(calculate_new_version "$current_version" "patch")
            update_version "$new_version"
            ;;
        "bump-minor")
            local current_version=$(get_current_version)
            local new_version=$(calculate_new_version "$current_version" "minor")
            update_version "$new_version"
            ;;
        "bump-major")
            local current_version=$(get_current_version)
            local new_version=$(calculate_new_version "$current_version" "major")
            update_version "$new_version"
            ;;
        "set")
            if [ -z "$version" ]; then
                print_error "Version required for 'set' action"
                echo "Usage: $0 set VERSION"
                exit 1
            fi
            update_version "$version"
            ;;
        "show")
            show_version
            ;;
        *)
            echo "Release System Version Manager"
            echo ""
            echo "Usage: $0 [COMMAND]"
            echo ""
            echo "Commands:"
            echo "  bump-patch    - Bump patch version (1.0.0 → 1.0.1)"
            echo "  bump-minor    - Bump minor version (1.0.0 → 1.1.0)"
            echo "  bump-major    - Bump major version (1.0.0 → 2.0.0)"
            echo "  set VERSION   - Set specific version (e.g., 1.2.3)"
            echo "  show          - Show current version"
            echo ""
            echo "Examples:"
            echo "  $0 bump-patch"
            echo "  $0 set 1.0.0"
            echo "  $0 show"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
