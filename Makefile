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

# Version bumping targets
bump-patch:
	@echo "Bumping patch version..."
	@./scripts/bump_version.sh patch

bump-minor:
	@echo "Bumping minor version..."
	@./scripts/bump_version.sh minor

bump-major:
	@echo "Bumping major version..."
	@./scripts/bump_version.sh major

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

release-patch: bump-patch
	@echo "Creating patch release..."
	@$(MAKE) release

release-minor: bump-minor
	@echo "Creating minor release..."
	@$(MAKE) release

release-major: bump-major
	@echo "Creating major release..."
	@$(MAKE) release

# Prerequisites check
check-prerequisites:
	@echo "Checking prerequisites..."
	@if [ ! -f "src/YOUR_CANISTER/Cargo.toml" ] && [ ! -f "Cargo.toml" ]; then \
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
	@echo "Interactive commit fixing..."
	@LAST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo ""); \
	if [ -n "$$LAST_TAG" ]; then \
		echo "Starting interactive rebase from $$LAST_TAG..."; \
		echo ""; \
		echo "📝 Instructions:"; \
		echo "1. In the editor that opens, you'll see a list of commits"; \
		echo "2. Change 'pick' to 'reword' for commits you want to edit"; \
		echo "3. Save and close the editor (Ctrl+X in nano, :wq in vim)"; \
		echo "4. For each 'reword' commit, another editor will open"; \
		echo "5. Edit the commit message to add conventional prefixes:"; \
		echo "   - feat: for new features"; \
		echo "   - fix: for bug fixes"; \
		echo "   - docs: for documentation"; \
		echo "   - chore: for maintenance"; \
		echo "6. Save and close each editor"; \
		echo ""; \
		echo "💡 Tips:"; \
		echo "- If you want to cancel, change 'pick' to 'drop'"; \
		echo "- If you make a mistake, run 'git rebase --abort'"; \
		echo "- To continue after fixing conflicts: 'git rebase --continue'"; \
		echo ""; \
		read -p "Press Enter to continue with interactive rebase..." || true; \
		git rebase -i $$LAST_TAG; \
		echo ""; \
		echo "✅ Interactive rebase completed!"; \
		echo "📋 Run 'make check-commits' to verify the changes."; \
	else \
		echo "❌ No previous tag found. Cannot start interactive rebase."; \
		echo "Please create a tag first: git tag v0.1.0"; \
	fi

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
add-changelog-entry:
	@echo "Adding changelog entry for version $(CURRENT_VERSION)..."
	@TODAY=$$(date +%Y-%m-%d); \
	cp CHANGELOG.md CHANGELOG.md.backup; \
	head -n 6 CHANGELOG.md.backup > CHANGELOG.md; \
	echo "" >> CHANGELOG.md; \
	echo "## [$(CURRENT_VERSION)] - $$TODAY" >> CHANGELOG.md; \
	echo "" >> CHANGELOG.md; \
	$(MAKE) generate-changelog-content >> CHANGELOG.md; \
	echo "" >> CHANGELOG.md; \
	tail -n +7 CHANGELOG.md.backup >> CHANGELOG.md; \
	rm CHANGELOG.md.backup
	@echo "✅ Added changelog entry for version $(CURRENT_VERSION)"
	@echo "📝 Please review and edit CHANGELOG.md if needed"

# Generate changelog content from git commits
generate-changelog-content:
	@LAST_TAG=$$(git describe --tags --abbrev=0 2>/dev/null || echo ""); \
	HAS_ADDED=false; \
	HAS_CHANGED=false; \
	HAS_FIXED=false; \
	HAS_REMOVED=false; \
	HAS_DEPRECATED=false; \
	HAS_SECURITY=false; \
	HAS_MAINTENANCE=false; \
	echo "### Added"; \
	if [ -n "$$LAST_TAG" ]; then \
		ADDED_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -E "^[a-f0-9]+ (feat|add|new|implement):" | head -10 | cut -d' ' -f2-); \
		if [ -n "$$ADDED_COMMITS" ]; then \
			echo "$$ADDED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_ADDED=true; \
		fi; \
	else \
		ADDED_COMMITS=$$(git log --oneline --since="1 month ago" | grep -E "^[a-f0-9]+ (feat|add|new|implement):" | head -10 | cut -d' ' -f2-); \
		if [ -n "$$ADDED_COMMITS" ]; then \
			echo "$$ADDED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_ADDED=true; \
		fi; \
	fi; \
	echo ""; \
	echo "### Changed"; \
	if [ -n "$$LAST_TAG" ]; then \
		CHANGED_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -E "^[a-f0-9]+ (change|update|modify|improve):" | head -10 | cut -d' ' -f2-); \
		if [ -n "$$CHANGED_COMMITS" ]; then \
			echo "$$CHANGED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_CHANGED=true; \
		fi; \
	else \
		CHANGED_COMMITS=$$(git log --oneline --since="1 month ago" | grep -E "^[a-f0-9]+ (change|update|modify|improve):" | head -10 | cut -d' ' -f2-); \
		if [ -n "$$CHANGED_COMMITS" ]; then \
			echo "$$CHANGED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_CHANGED=true; \
		fi; \
	fi; \
	echo ""; \
	echo "### Fixed"; \
	if [ -n "$$LAST_TAG" ]; then \
		FIXED_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -E "^[a-f0-9]+ (fix|bugfix|resolve):" | head -10 | cut -d' ' -f2-); \
		if [ -n "$$FIXED_COMMITS" ]; then \
			echo "$$FIXED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_FIXED=true; \
		fi; \
	else \
		FIXED_COMMITS=$$(git log --oneline --since="1 month ago" | grep -E "^[a-f0-9]+ (fix|bugfix|resolve):" | head -10 | cut -d' ' -f2-); \
		if [ -n "$$FIXED_COMMITS" ]; then \
			echo "$$FIXED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_FIXED=true; \
		fi; \
	fi; \
	echo ""; \
	echo "### Removed"; \
	if [ -n "$$LAST_TAG" ]; then \
		REMOVED_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -E "^[a-f0-9]+ (remove|delete|drop):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$REMOVED_COMMITS" ]; then \
			echo "$$REMOVED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_REMOVED=true; \
		fi; \
	else \
		REMOVED_COMMITS=$$(git log --oneline --since="1 month ago" | grep -E "^[a-f0-9]+ (remove|delete|drop):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$REMOVED_COMMITS" ]; then \
			echo "$$REMOVED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_REMOVED=true; \
		fi; \
	fi; \
	echo ""; \
	echo "### Deprecated"; \
	if [ -n "$$LAST_TAG" ]; then \
		DEPRECATED_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -E "^[a-f0-9]+ (deprecate|deprecated):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$DEPRECATED_COMMITS" ]; then \
			echo "$$DEPRECATED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_DEPRECATED=true; \
		fi; \
	else \
		DEPRECATED_COMMITS=$$(git log --oneline --since="1 month ago" | grep -E "^[a-f0-9]+ (deprecate|deprecated):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$DEPRECATED_COMMITS" ]; then \
			echo "$$DEPRECATED_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_DEPRECATED=true; \
		fi; \
	fi; \
	echo ""; \
	echo "### Security"; \
	if [ -n "$$LAST_TAG" ]; then \
		SECURITY_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -E "^[a-f0-9]+ (security|secure):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$SECURITY_COMMITS" ]; then \
			echo "$$SECURITY_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_SECURITY=true; \
		fi; \
	else \
		SECURITY_COMMITS=$$(git log --oneline --since="1 month ago" | grep -E "^[a-f0-9]+ (security|secure):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$SECURITY_COMMITS" ]; then \
			echo "$$SECURITY_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_SECURITY=true; \
		fi; \
	fi; \
	echo ""; \
	echo "### Maintenance"; \
	if [ -n "$$LAST_TAG" ]; then \
		MAINTENANCE_COMMITS=$$(git log --oneline $$LAST_TAG..HEAD | grep -E "^[a-f0-9]+ (chore|refactor|cleanup|docs|test|ci|build|style|perf):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$MAINTENANCE_COMMITS" ]; then \
			echo "$$MAINTENANCE_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_MAINTENANCE=true; \
		fi; \
	else \
		MAINTENANCE_COMMITS=$$(git log --oneline --since="1 month ago" | grep -E "^[a-f0-9]+ (chore|refactor|cleanup|docs|test|ci|build|style|perf):" | head -5 | cut -d' ' -f2-); \
		if [ -n "$$MAINTENANCE_COMMITS" ]; then \
			echo "$$MAINTENANCE_COMMITS" | while read commit; do \
				if [ -n "$$commit" ]; then \
					echo "- $$commit"; \
				fi; \
			done; \
			HAS_MAINTENANCE=true; \
		fi; \
	fi
