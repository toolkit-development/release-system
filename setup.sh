#!/bin/bash

# Release System Setup Script
# This script downloads and installs the complete release system into any repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
RELEASE_SYSTEM_REPO="toolkit-development/release-system"
RELEASE_SYSTEM_BRANCH="master"
TEMP_DIR="/tmp/release-system-setup"

# Print colored output
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

# Check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_error "Not in a git repository. Please run this script from within a git repository."
        exit 1
    fi
    print_success "Git repository detected"
}

# Check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check for required tools
    local missing_tools=()
    
    for tool in curl git make; do
        if ! command -v "$tool" > /dev/null 2>&1; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        print_error "Missing required tools: ${missing_tools[*]}"
        print_info "Please install the missing tools and try again."
        exit 1
    fi
    
    print_success "All prerequisites met"
}

# Download release system files
download_release_system() {
    print_info "Downloading release system files..."
    
    # Create temporary directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR"
    
    # Files to download from release-system repository
    local files=(
        "Makefile"
        "RELEASE.md"
        "scripts/setup-release-system.sh"
        ".github-templates/workflows/ci-cd.yml"
        ".github-templates/workflows/release.yml"
        ".github-templates/workflows/manual-deploy.yml"
        ".github-templates/scripts/extract-nns-state.sh"
        ".github-templates/scripts/create_checksums.sh"
        ".github-templates/scripts/setup-nns-state.sh"
        ".github-templates/scripts/README.md"
        ".github-templates/scripts/build.sh"
        ".github-templates/scripts/add_prod_release_body.sh"
        ".github-templates/scripts/generate_changelog.sh"
        ".github-templates/actions/deploy/action.yml"
        ".github-templates/actions/release/action.yml"
        ".github-templates/actions/build/action.yml"
    )
    
    # Download files from release-system repository
    for file in "${files[@]}"; do
        local url="https://raw.githubusercontent.com/$RELEASE_SYSTEM_REPO/$RELEASE_SYSTEM_BRANCH/$file"
        local target_dir="$TEMP_DIR/$(dirname "$file")"
        
        mkdir -p "$target_dir"
        
        if curl -fsSL "$url" -o "$TEMP_DIR/$file" 2>/dev/null; then
            print_success "Downloaded $file"
        else
            print_warning "Failed to download $file (will be created from template)"
        fi
    done
    
    print_success "Download complete"
}

# Create missing files from templates
create_template_files() {
    print_info "Creating template files..."
    
    # Create directory structure
    mkdir -p "$TEMP_DIR/scripts"
    mkdir -p "$TEMP_DIR/.github-templates/workflows"
    mkdir -p "$TEMP_DIR/.github-templates/scripts"
    mkdir -p "$TEMP_DIR/.github-templates/actions/deploy"
    mkdir -p "$TEMP_DIR/.github-templates/actions/release"
    mkdir -p "$TEMP_DIR/.github-templates/actions/build"
    
    # Create Makefile if not downloaded
    if [ ! -f "$TEMP_DIR/Makefile" ]; then
        cat > "$TEMP_DIR/Makefile" << 'EOF'
# Release System Makefile
# Automated release management for your project

.PHONY: help release-patch release-minor release-major check-commits fix-commits add-changelog generate-changelog-content

# Default target
help:
	@echo "Release System Commands:"
	@echo "  release-patch    - Create a patch release (0.1.0 → 0.1.1)"
	@echo "  release-minor    - Create a minor release (0.1.0 → 0.2.0)"
	@echo "  release-major    - Create a major release (0.1.0 → 1.0.0)"
	@echo "  check-commits    - Check if commits follow conventions"
	@echo "  fix-commits      - Interactive rebase to fix commit messages"
	@echo "  add-changelog    - Add a new changelog entry"
	@echo "  generate-changelog-content - Generate changelog from commits"

# Get current version from Cargo.toml
CURRENT_VERSION := $(shell grep '^version = ' Cargo.toml | cut -d'"' -f2)
MAJOR := $(shell echo $(CURRENT_VERSION) | cut -d. -f1)
MINOR := $(shell echo $(CURRENT_VERSION) | cut -d. -f2)
PATCH := $(shell echo $(CURRENT_VERSION) | cut -d. -f3)

# Calculate new versions
NEW_PATCH_VERSION := $(MAJOR).$(MINOR).$(shell echo $(PATCH) + 1 | bc)
NEW_MINOR_VERSION := $(MAJOR).$(shell echo $(MINOR) + 1 | bc).0
NEW_MAJOR_VERSION := $(shell echo $(MAJOR) + 1 | bc).0.0

# Release targets
release-patch:
	@echo "Creating patch release $(NEW_PATCH_VERSION)..."
	@$(MAKE) _create-release VERSION=$(NEW_PATCH_VERSION)

release-minor:
	@echo "Creating minor release $(NEW_MINOR_VERSION)..."
	@$(MAKE) _create-release VERSION=$(NEW_MINOR_VERSION)

release-major:
	@echo "Creating major release $(NEW_MAJOR_VERSION)..."
	@$(MAKE) _create-release VERSION=$(NEW_MAJOR_VERSION)

# Internal release creation
_create-release:
	@echo "Checking prerequisites..."
	@$(MAKE) check-commit-conventions
	@echo "✅ Prerequisites check passed"
	@echo "Starting release process..."
	@echo "Current version: $(CURRENT_VERSION)"
	@echo "New version: $(VERSION)"
	@echo "Checking CHANGELOG.md for version $(VERSION)..."
	@if ! grep -q "## \[$(VERSION)\]" CHANGELOG.md; then \
		echo "⚠️  Warning: No changelog entry found for version $(VERSION)"; \
		read -p "Would you like to add a placeholder entry? (y/n) " -n 1 -r; \
		echo; \
		if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
			echo "Adding placeholder changelog entry..."; \
			$(MAKE) add-changelog-entry VERSION=$(VERSION); \
		fi; \
	fi
	@echo "📝 Please review and edit CHANGELOG.md if needed"
	@echo "Please ensure you have:"
	@echo "1. Updated CHANGELOG.md with release notes"
	@echo "2. Committed all changes"
	@echo "3. Pushed to remote"
	@read -p "Press Enter to continue with release tag creation..."
	@echo "Creating git tag v$(VERSION)..."
	@git tag -a v$(VERSION) -m "Release v$(VERSION)"
	@echo "Pushing tag to remote..."
	@git push origin v$(VERSION)
	@echo "✅ Release v$(VERSION) created and pushed!"

# Commit convention checks
check-commits:
	@$(MAKE) check-commit-conventions

check-commit-conventions:
	@echo "Checking commit message conventions..."
	@if git log --oneline | grep -vE '^[a-f0-9]+ (feat|add|fix|docs|style|refactor|test|chore|ci|build|perf|revert):'; then \
		echo "❌ Some commits don't follow conventional format"; \
		echo "Run 'make fix-commits' to fix them interactively"; \
		exit 1; \
	else \
		echo "✅ All commits follow conventional format"; \
	fi

fix-commits:
	@echo "Starting interactive rebase to fix commit messages..."
	@echo "This will open an editor where you can modify commit messages."
	@echo "Make sure to save and exit the editor properly:"
	@echo "  - Vim: Press 'Esc', then type ':wq' and press Enter"
	@echo "  - VS Code: Press Ctrl+S to save, then Ctrl+Q to quit"
	@echo "  - Nano: Press Ctrl+X, then Y, then Enter"
	@echo ""
	@read -p "Press Enter to continue..."
	@git rebase -i HEAD~$(shell git log --oneline | wc -l)
	@echo "✅ Rebase completed. If you made changes, you may need to force push:"
	@echo "   git push --force-with-lease origin main"

# Changelog management
add-changelog:
	@read -p "Enter version (e.g., 0.1.0): " version; \
	$(MAKE) add-changelog-entry VERSION=$$version

add-changelog-entry:
	@echo "Adding changelog entry for version $(VERSION)..."
	@if [ ! -f CHANGELOG.md ]; then \
		echo "# Changelog" > CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "All notable changes to this project will be documented in this file." >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
	fi
	@if ! grep -q "## \[$(VERSION)\]" CHANGELOG.md; then \
		cp CHANGELOG.md CHANGELOG.md.tmp; \
		head -n 4 CHANGELOG.md.tmp > CHANGELOG.md; \
		echo "## [$(VERSION)] - $(date +%Y-%m-%d)" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "### Added" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "### Changed" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "### Fixed" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "### Removed" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "### Deprecated" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "### Security" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		echo "### Maintenance" >> CHANGELOG.md; \
		echo "" >> CHANGELOG.md; \
		tail -n +5 CHANGELOG.md.tmp >> CHANGELOG.md; \
		rm CHANGELOG.md.tmp; \
		echo "✅ Added changelog entry for version $(VERSION)"; \
	else \
		echo "⚠️  Changelog entry for version $(VERSION) already exists"; \
	fi

generate-changelog-content:
	@echo "Generating changelog content from commits..."
	@echo "### Changes" >> CHANGELOG.md
	@git log --oneline --no-merges $(shell git describe --tags --abbrev=0 2>/dev/null || echo "")..HEAD | cut -d' ' -f2- | sed 's/^/- /' >> CHANGELOG.md
	@echo "✅ Changelog content generated"
EOF
    fi
    
    # Create RELEASE.md if not downloaded
    if [ ! -f "$TEMP_DIR/RELEASE.md" ]; then
        cat > "$TEMP_DIR/RELEASE.md" << 'EOF'
# Release Guide

Quick guide for creating releases in this repository.

## Quick Release

1. **Make changes and commit with conventional format:**
   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

2. **Create a release:**
   ```bash
   make release-patch    # 0.1.0 → 0.1.1
   make release-minor    # 0.1.0 → 0.2.0
   make release-major    # 0.1.0 → 1.0.0
   ```

3. **Review changelog and push:**
   ```bash
   git add CHANGELOG.md
   git commit -m "docs: update changelog"
   git push origin main
   ```

## Manual Release Process

1. **Check commit conventions:**
   ```bash
   make check-commits
   ```

2. **Fix any non-conventional commits:**
   ```bash
   make fix-commits
   ```

3. **Add changelog entry:**
   ```bash
   make add-changelog
   ```

4. **Create and push tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## Commit Message Rules

All commits must follow this format:
```
<type>: <description>

Examples:
feat: add user authentication
fix: resolve login timeout
docs: update API documentation
chore: update dependencies
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Common Issues

**"Commit message doesn't follow conventions"**
- Use `make fix-commits` to rebase and fix
- Or amend the last commit: `git commit --amend -m "feat: correct message"`

**"Can't push after rebase"**
- Use: `git push --force-with-lease origin main`

**"Changelog not updating"**
- Run: `make add-changelog`
- Or: `make generate-changelog-content`

## What Happens After Release

1. GitHub Actions creates a release automatically
2. Assets are built and uploaded
3. Release notes are generated from changelog
4. Deployment to production (if configured)

## Need Help?

- Check the `Makefile` for all available commands
- Review GitHub Actions logs for deployment issues
- See the main README.md for detailed documentation
EOF
    fi
    
    # Create CHANGELOG.md if not downloaded
    if [ ! -f "$TEMP_DIR/CHANGELOG.md" ]; then
        cat > "$TEMP_DIR/CHANGELOG.md" << 'EOF'
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

### Changed

### Fixed

### Removed

### Deprecated

### Security
EOF
    fi
    
    print_success "Template files created"
}

# Install the release system
install_release_system() {
    print_info "Installing release system..."
    
    # Copy files to current directory (including hidden files)
    # Enable dotglob for bash, or use alternative for zsh
    if [ -n "$BASH_VERSION" ]; then
        shopt -s dotglob 2>/dev/null || true
        cp -r "$TEMP_DIR"/* .
        shopt -u dotglob 2>/dev/null || true
    else
        # For zsh or other shells, copy hidden files explicitly
        cp -r "$TEMP_DIR"/* . 2>/dev/null || true
        cp -r "$TEMP_DIR"/.[^.]* . 2>/dev/null || true
    fi
    
    # Rename .github-templates to .github if it exists
    if [ -d ".github-templates" ]; then
        mv .github-templates .github
        print_success "Renamed .github-templates to .github"
    fi
    
    # Make scripts executable
    chmod +x scripts/setup-release-system.sh 2>/dev/null || true
    chmod +x .github/scripts/*.sh 2>/dev/null || true
    
    # Create git hook for commit message validation
    print_info "Setting up git hooks..."
    mkdir -p .git/hooks
    
    cat > .git/hooks/commit-msg << 'EOF'
#!/bin/bash

# Conventional commit message validator
commit_msg=$(cat "$1")

# Check if message follows conventional format
if ! echo "$commit_msg" | grep -qE '^(feat|add|fix|docs|style|refactor|test|chore|ci|build|perf|revert)(\(.+\))?: .+'; then
    echo "❌ Commit message doesn't follow conventional format"
    echo "Format: <type>: <description>"
    echo "Types: feat, add, fix, docs, style, refactor, test, chore, ci, build, perf, revert"
    echo "Example: feat: add user authentication"
    exit 1
fi

echo "✅ Commit message follows conventional format"
EOF
    
    chmod +x .git/hooks/commit-msg
    
    print_success "Release system installed successfully"
}

# Update version in Cargo.toml if it exists
update_cargo_version() {
    if [ -f "Cargo.toml" ]; then
        print_info "Updating Cargo.toml version..."
        if ! grep -q '^version = ' Cargo.toml; then
            print_warning "No version found in Cargo.toml, adding version 0.1.0"
            # Add version after [package] section, not at the beginning
            if grep -q '^\[package\]' Cargo.toml; then
                # Insert after [package] line
                sed -i.bak '/^\[package\]/a\
version = "0.1.0"
' Cargo.toml
            elif grep -q '^\[workspace\]' Cargo.toml; then
                # For workspace projects, don't add version at all
                print_warning "Workspace project detected, skipping version addition"
            else
                # If no [package] section, add at the beginning
                sed -i.bak '1i\
version = "0.1.0"
' Cargo.toml
            fi
        fi
        print_success "Cargo.toml version configured"
    fi
}

# Cleanup
cleanup() {
    print_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    print_success "Cleanup complete"
}

# Main execution
main() {
    echo "🚀 Release System Setup"
    echo "========================"
    echo ""
    
    check_git_repo
    check_prerequisites
    download_release_system
    create_template_files
    install_release_system
    update_cargo_version
    cleanup
    
    echo ""
    echo "🎉 Release system installed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Review the installed files"
    echo "2. Customize the configuration for your project"
    echo "3. Make your first commit with conventional format:"
    echo "   git add ."
    echo "   git commit -m 'feat: add release system'"
    echo "4. Create your first release:"
    echo "   make release-patch"
    echo ""
    echo "📖 See RELEASE.md for detailed usage instructions"
    echo "📖 See README.md for comprehensive documentation"
}

# Run main function
main "$@" 