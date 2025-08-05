# Release Guide

This guide explains how to create a new release for contributors.

## 🚀 Quick Release (Recommended)

### Step 1: Prepare Your Changes

```bash
# Ensure all changes are committed
git status
git add .
git commit -m "feat: your changes description"
```

### Step 2: Choose Release Type

- **Patch** (0.1.0 → 0.1.1): Bug fixes, small improvements
- **Minor** (0.1.0 → 0.2.0): New features, backward compatible
- **Major** (0.1.0 → 1.0.0): Breaking changes

### Step 3: Create Release

```bash
# Automated release (recommended)
make release-patch    # or release-minor, release-major

# OR interactive release
make interactive-release
```

That's it! The system will automatically:

- ✅ Bump version in Cargo.toml
- ✅ Generate changelog entry
- ✅ Create and push git tag
- ✅ Trigger GitHub release pipeline

## 📋 Manual Release Process

If you prefer manual control:

### Step 1: Update Version

```bash
# Edit src/user_registry/Cargo.toml
# Change version = "0.1.0" to "0.1.1"
```

### Step 2: Update Changelog

```bash
# Add entry at top of CHANGELOG.md
## [0.1.1] - 2025-01-27

### Added
- Your new features

### Changed
- Your modifications

### Fixed
- Your bug fixes
```

### Step 3: Commit and Tag

```bash
git add .
git commit -m "feat: release version 0.1.1"
git tag -a v0.1.1 -m "Release v0.1.1"
git push origin v0.1.1
```

## 🔒 Commit Message Rules

**All commits must use these prefixes:**

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation
- `chore:` - Maintenance
- `refactor:` - Code refactoring
- `test:` - Adding tests
- `ci:` - CI/CD changes

**Examples:**

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve memory leak"
git commit -m "docs: update API documentation"
```

## ⚠️ Common Issues

### "Commit message does not follow conventional format"

- Use one of the required prefixes (feat:, fix:, docs:, etc.)
- Example: `git commit -m "feat: add new feature"`

### "Working directory is not clean"

- Commit or stash your changes before releasing
- `git add . && git commit -m "feat: your changes"`

### "Cannot push after rebase"

- Use `git push --force-with-lease origin master`
- Only if you're the only one working on the branch

## 📊 What Happens After Release

1. **GitHub Actions** automatically:

   - Builds the canister
   - Deploys to development
   - Creates GitHub release
   - Uploads assets (WASM, Candid, checksums)

2. **Release assets** include:
   - `user_registry.wasm.gz` - Compiled canister
   - `user_registry.did` - Candid interface
   - `canister_ids.json` - Canister identifiers

## 🆘 Need Help?

- **Check commands**: `make help`
- **View changes**: `make show-changes`
- **Check status**: `make show-status`
- **Run tests**: `make test`

---

**Remember**: Always use conventional commit messages and ensure your working directory is clean before releasing!
