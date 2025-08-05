#!/bin/bash

# Test script for the release system setup
# This script creates a temporary repository and tests the installation

set -e

# Create test repository
create_test_repo() {
    echo "Creating test repository..."
    
    TEST_DIR="/tmp/release-system-test-$(date +%s)"
    mkdir -p "$TEST_DIR"
    cd "$TEST_DIR"
    
    # Initialize git repository
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create a simple Cargo.toml
    cat > Cargo.toml << 'EOF'
[package]
name = "test-project"
version = "0.1.0"
edition = "2021"

[dependencies]
EOF
    
    # Create initial commit
    git add Cargo.toml
    git commit -m "feat: initial commit"
    
    echo "Test repository created at $TEST_DIR"
    echo "$TEST_DIR"
    cd - > /dev/null 2>&1
}

# Test the installation
test_installation() {
    local test_dir="$1"
    cd "$test_dir"
    
    echo "Testing release system installation..."
    
    # Run the setup script
    if [ -f "setup.sh" ]; then
        chmod +x setup.sh
        ./setup.sh
    else
        echo "ERROR: Setup script not found"
        return 1
    fi
    
    # Test that files were created
    local required_files=("Makefile" "RELEASE.md" "CHANGELOG.md" ".git/hooks/commit-msg")
    
    for file in "${required_files[@]}"; do
        if [ -f "$file" ]; then
            echo "✓ $file created"
        else
            echo "✗ $file not found"
            return 1
        fi
    done
    
    # Test make help
    if make help > /dev/null 2>&1; then
        echo "✓ Makefile works"
    else
        echo "✗ Makefile not working"
        return 1
    fi
    
    # Test commit hook
    echo "test: invalid commit" > test_commit.txt
    if ! git commit -F test_commit.txt 2>&1 | grep -q "doesn't follow conventional format"; then
        echo "✗ Commit hook not working"
        return 1
    else
        echo "✓ Commit hook working"
    fi
    
    # Test valid commit
    echo "feat: add test feature" > test_commit.txt
    if git commit -F test_commit.txt 2>&1 | grep -q "follows conventional format"; then
        echo "✓ Valid commit accepted"
    else
        echo "✗ Valid commit rejected"
        return 1
    fi
    
    rm -f test_commit.txt
    
    echo "All tests passed!"
}

# Cleanup
cleanup() {
    local test_dir="$1"
    if [ -n "$test_dir" ] && [ -d "$test_dir" ]; then
        echo "Cleaning up test repository..."
        rm -rf "$test_dir"
        echo "Cleanup complete"
    fi
}

# Main execution
main() {
    echo "🧪 Release System Test"
    echo "======================"
    echo ""
    
    local test_dir=""
    
    # Trap to ensure cleanup on exit
    trap 'cleanup "$test_dir"' EXIT
    
    # Create test repository
    test_dir=$(create_test_repo)
    
    # Copy setup script to test directory
    if [ -f "setup.sh" ]; then
        cp setup.sh "$test_dir/" 2>/dev/null || echo "Warning: Could not copy setup.sh"
    else
        echo "ERROR: Setup script not found in current directory"
        return 1
    fi
    
    # Test installation
    if test_installation "$test_dir"; then
        echo ""
        echo "🎉 All tests passed! Release system is working correctly."
        echo ""
        echo "To use in your repository:"
        echo "curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/main/install.sh | bash"
    else
        echo ""
        echo "❌ Tests failed! Please check the setup."
        exit 1
    fi
}

# Run main function
main "$@" 