# User Registry Makefile
# Provides easy commands for version management and releases

.PHONY: help bump-patch bump-minor bump-major release check-version clean build test

# Default target
help:
	@echo "User Registry - Available Commands:"
	@echo ""
	@echo "Version Management:"
	@echo "  bump-patch    - Bump patch version (0.1.0 -> 0.1.1)"
	@echo "  bump-minor    - Bump minor version (0.1.0 -> 0.2.0)"
	@echo "  bump-major    - Bump major version (0.1.0 -> 1.0.0)"
	@echo "  check-version - Show current version"
	@echo ""
	@echo "Release Process:"
	@echo "  release       - Complete release process (bump + tag + push)"
	@echo "  release-patch - Release with patch version bump"
	@echo "  release-minor - Release with minor version bump"
	@echo "  release-major - Release with major version bump"
	@echo ""
	@echo "Changelog Management:"
	@echo "  add-changelog-entry     - Add changelog entry for current version"
	@echo "  generate-changelog-content - Show changelog content from git commits"
	@echo ""
	@echo "Commit Management:"
	@echo "  check-commits     - Check if commits follow conventional format"
	@echo "  fix-commits       - Interactive rebase to fix commit messages"
	@echo "  quick-fix-commits - Automatically fix common commit patterns"
	@echo ""
	@echo "Development:"
	@echo "  build         - Build the project"
	@echo "  test          - Run tests"
	@echo "  clean         - Clean build artifacts"
	@echo ""

# Get current version from Cargo.toml
# Try to find version in the correct location (workspace vs package)
CURRENT_VERSION := $(shell if [ -f "src/YOUR_CANISTER/Cargo.toml" ]; then grep '^version = ' src/YOUR_CANISTER/Cargo.toml | cut -d'"' -f2; else grep '^version = ' Cargo.toml | cut -d'"' -f2; fi)
MAJOR := $(shell echo $(CURRENT_VERSION) | cut -d. -f1)
MINOR := $(shell echo $(CURRENT_VERSION) | cut -d. -f2)
PATCH := $(shell echo $(CURRENT_VERSION) | cut -d. -f3)

# Calculate new versions
NEW_PATCH_VERSION := $(MAJOR).$(MINOR).$(shell echo $(PATCH) + 1 | bc)
NEW_MINOR_VERSION := $(MAJOR).$(shell echo $(MINOR) + 1 | bc).0
NEW_MAJOR_VERSION := $(shell echo $(MAJOR) + 1 | bc).0.0

# Version bumping targets
bump-patch:
	@echo "Bumping patch version to $(NEW_PATCH_VERSION)..."
	@if [ -f "src/YOUR_CANISTER/Cargo.toml" ]; then \
		sed -i.bak 's/^version = ".*"/version = "$(NEW_PATCH_VERSION)"/' src/YOUR_CANISTER/Cargo.toml; \
	else \
		sed -i.bak 's/^version = ".*"/version = "$(NEW_PATCH_VERSION)"/' Cargo.toml; \
	fi
	@echo "✅ Version bumped to $(NEW_PATCH_VERSION)"

bump-minor:
	@echo "Bumping minor version to $(NEW_MINOR_VERSION)..."
	@if [ -f "src/YOUR_CANISTER/Cargo.toml" ]; then \
		sed -i.bak 's/^version = ".*"/version = "$(NEW_MINOR_VERSION)"/' src/YOUR_CANISTER/Cargo.toml; \
	else \
		sed -i.bak 's/^version = ".*"/version = "$(NEW_MINOR_VERSION)"/' Cargo.toml; \
	fi
	@echo "✅ Version bumped to $(NEW_MINOR_VERSION)"

bump-major:
	@echo "Bumping major version to $(NEW_MAJOR_VERSION)..."
	@if [ -f "src/YOUR_CANISTER/Cargo.toml" ]; then \
		sed -i.bak 's/^version = ".*"/version = "$(NEW_MAJOR_VERSION)"/' src/YOUR_CANISTER/Cargo.toml; \
	else \
		sed -i.bak 's/^version = ".*"/version = "$(NEW_MAJOR_VERSION)"/' Cargo.toml; \
	fi
	@echo "✅ Version bumped to $(NEW_MAJOR_VERSION)"

check-version:
	@echo "Current version: $(CURRENT_VERSION)"

# Release process targets
release: check-prerequisites
	@echo "Starting release process..."
	@echo "Current version: $(CURRENT_VERSION)"
	@echo ""
	@echo "Checking CHANGELOG.md for version $(CURRENT_VERSION)..."
	@if ! grep -q "## \[$(CURRENT_VERSION)\]" CHANGELOG.md; then \
		echo "⚠️  Warning: No changelog entry found for version $(CURRENT_VERSION)"; \
		echo "Would you like to add a placeholder entry? (y/n)"; \
		read -p "" add_changelog; \
		if [ "$$add_changelog" = "y" ] || [ "$$add_changelog" = "Y" ]; then \
			echo "Adding placeholder changelog entry..."; \
			$(MAKE) add-changelog-entry; \
		fi; \
	fi
	@echo ""
	@echo "Please ensure you have:"
	@echo "1. Updated CHANGELOG.md with release notes"
	@echo "2. Committed all changes"
	@echo "3. Pushed to remote"
	@echo ""
	@read -p "Press Enter to continue with release tag creation..." || true
	@echo "Creating git tag v$(CURRENT_VERSION)..."
	@git tag -a v$(CURRENT_VERSION) -m "Release v$(CURRENT_VERSION)"
	@echo "Pushing tag to remote..."
	@git push origin v$(CURRENT_VERSION)
	@echo "✅ Release v$(CURRENT_VERSION) created and pushed!"

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

# Prerequisites check
check-prerequisites:
	@echo "Checking prerequisites..."
	@if [ ! -f "Cargo.toml" ] && [ ! -f "src/YOUR_CANISTER/Cargo.toml" ]; then \
		echo "❌ Cargo.toml not found in root or src/YOUR_CANISTER/"; \
		exit 1; \
	fi
	@if [ ! -f "CHANGELOG.md" ]; then \
		echo "❌ CHANGELOG.md not found"; \
		exit 1; \
	fi
	@if ! git status --porcelain | grep -q .; then \
		echo "❌ Working directory is not clean. Please commit all changes first."; \
		exit 1; \
	fi
	@$(MAKE) check-commit-conventions
	@echo "✅ Prerequisites check passed"

# Check commit message conventions
check-commit-conventions:
	@echo "Checking commit message conventions..."
	@LAST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo ""); \
	if [ -n "$$LAST_TAG" ]; then \
		INVALID_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -vE "^[a-f0-9]+ (feat|add|new|implement|change|update|modify|improve|fix|bugfix|resolve|chore|refactor|cleanup|docs|revert|test|ci|build|style|perf):" | head -5); \
		if [ -n "$$INVALID_COMMITS" ]; then \
			echo "❌ Found commits without conventional prefixes:"; \
			echo "$$INVALID_COMMITS"; \
			echo ""; \
			echo "Please use conventional commit prefixes:"; \
			echo "  feat:, add:, new:, implement: - New features"; \
			echo "  change:, update:, modify:, improve: - Changes"; \
			echo "  fix:, bugfix:, resolve: - Bug fixes"; \
			echo "  chore:, refactor:, cleanup:, docs: - Maintenance"; \
			echo ""; \
			echo "Examples:"; \
			echo "  git commit -m \"feat: add user authentication\""; \
			echo "  git commit -m \"fix: resolve memory leak\""; \
			echo "  git commit -m \"docs: update README\""; \
			echo ""; \
			echo "To fix existing commits, use interactive rebase:"; \
			echo "  git rebase -i $$LAST_TAG"; \
			exit 1; \
		fi; \
		echo "✅ All commits follow conventional format"; \
	else \
		echo "⚠️  No previous tag found, skipping commit convention check"; \
	fi

# Development targets
build:
	@echo "Building project..."
	@cargo build

test:
	@echo "Running tests..."
	@cargo test

clean:
	@echo "Cleaning build artifacts..."
	@cargo clean
	@rm -rf target/
	@rm -rf wasm/

# Utility targets
show-changes:
	@echo "Recent changes:"
	@git log --oneline -10

show-status:
	@echo "Git status:"
	@git status --short

check-commits:
	@$(MAKE) check-commit-conventions

# Quick fix for the most common commit message patterns
quick-fix-commits:
	@echo "Quick commit message fixing..."
	@LAST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo ""); \
	if [ -n "$$LAST_TAG" ]; then \
		echo "This will automatically fix common commit message patterns:"; \
		echo "- 'update' -> 'chore: update'"; \
		echo "- 'Add' -> 'feat: add'"; \
		echo "- 'fix' -> 'fix: fix'"; \
		echo "- 'docs' -> 'docs: docs'"; \
		echo ""; \
		read -p "Press Enter to continue with automatic fixing..." || true; \
		git filter-branch --msg-filter ' \
			sed -e "s/^update /chore: update /" \
				-e "s/^Add /feat: add /" \
				-e "s/^fix /fix: fix /" \
				-e "s/^docs /docs: docs /" \
		' $$LAST_TAG..HEAD; \
		echo ""; \
		echo "✅ Quick fix completed!"; \
		echo "📋 Run 'make check-commits' to verify the changes."; \
	else \
		echo "❌ No previous tag found. Cannot fix commits."; \
		echo "Please create a tag first: git tag v0.1.0"; \
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

# Interactive release helper
interactive-release:
	@echo "Interactive Release Helper"
	@echo "========================"
	@echo "Current version: $(CURRENT_VERSION)"
	@echo ""
	@echo "What type of release would you like to create?"
	@echo "1) Patch release (bug fixes)"
	@echo "2) Minor release (new features, backward compatible)"
	@echo "3) Major release (breaking changes)"
	@echo "4) Exit"
	@echo ""
	@read -p "Enter your choice (1-4): " choice; \
	case $$choice in \
		1) $(MAKE) release-patch ;; \
		2) $(MAKE) release-minor ;; \
		3) $(MAKE) release-major ;; \
		4) echo "Release cancelled." ;; \
		*) echo "Invalid choice. Please run 'make interactive-release' again." ;; \
	esac

# Add changelog entry for current version
