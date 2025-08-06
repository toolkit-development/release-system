# Release System Setup Reference

This document provides a comprehensive reference for understanding and setting up the release system in new repositories.

## 🎯 Current State

The release system is **fully functional** and ready to use. It provides:

- ✅ **GitHub Actions workflows** (CI/CD, releases, manual deployment)
- ✅ **Automated version bumping** and release creation
- ✅ **Conventional commit validation** via git hooks
- ✅ **Changelog generation** from git commits
- ✅ **Checksum verification** for security
- ✅ **NNS state management** for Internet Computer development

## 🚀 Quick Installation

```bash
curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash
```

## 📁 What Gets Installed

### Core Files

- `Makefile` - Version bumping and release commands
- `RELEASE.md` - Quick reference guide
- `CHANGELOG.md` - Empty changelog template
- `scripts/setup-release-system.sh` - Setup script template

### GitHub Actions (`.github/`)

- `workflows/ci-cd.yml` - Continuous integration and deployment
- `workflows/release.yml` - Automated releases
- `workflows/manual-deploy.yml` - Manual production deployment
- `scripts/` - Build, checksum, and changelog generation scripts
- `actions/` - Custom GitHub Actions for deploy, release, and build

### Git Hooks

- `.git/hooks/commit-msg` - Conventional commit validation

## ⚙️ Required Configuration

### 1. Repository-Specific Changes

**IMPORTANT**: The release system is designed for the `YOUR_CANISTER` project. You MUST update these references:

#### In `.github/workflows/ci-cd.yml`:

```yaml
# Change these lines:
VERSION=$(grep '^version = ' src/YOUR_CANISTER/Cargo.toml | cut -d'"' -f2)
# To match your project structure, e.g.:
VERSION=$(grep '^version = ' Cargo.toml | cut -d'"' -f2)
# or
VERSION=$(grep '^version = ' src/your-project/Cargo.toml | cut -d'"' -f2)
```

#### In `.github/workflows/manual-deploy.yml`:

```yaml
# Change these lines:
CURRENT_VERSION=$(grep '^version = ' src/YOUR_CANISTER/Cargo.toml | cut -d'"' -f2)
# To match your project structure
```

#### In `.github/scripts/build.sh`:

```bash
# Change these lines:
cargo build --target wasm32-unknown-unknown --package YOUR_CANISTER
# To match your project, e.g.:
cargo build --target wasm32-unknown-unknown --package your-project
```

#### In `.github/scripts/create_checksums.sh`:

```bash
# Change these lines:
WASM_FILE="wasm/YOUR_CANISTER.wasm.gz"
DID_FILE="YOUR_CANISTER.did"
# To match your project, e.g.:
WASM_FILE="wasm/your-project.wasm.gz"
DID_FILE="your-project.did"
```

### 2. GitHub Secrets Setup

The workflows require these secrets to be configured in your repository:

#### For Development Deployment:

- `IDENTITY_DEV` - PEM file content for dev network deployment

#### For Production Deployment:

- `IDENTITY_PROD` - PEM file content for production network deployment

#### Optional (for notifications):

- `SLACK_WEBHOOK_URL` - Slack webhook for deployment notifications
- `DISCORD_WEBHOOK_URL` - Discord webhook for deployment notifications

### 3. Internet Computer Specific Configuration

#### NNS State Setup:

The system includes NNS state management for Internet Computer development:

```bash
# The .github/scripts/setup-nns-state.sh script handles:
# - Downloading NNS state
# - Caching for faster builds
# - Extraction for tests
```

#### Canister Configuration:

Update canister IDs in your project:

- `canister_ids.json` - Development and production canister IDs
- Update deployment scripts to use correct canister names

### 4. Project Structure Assumptions

The system assumes this structure (modify as needed):

```
your-project/
├── Cargo.toml (or src/your-project/Cargo.toml)
├── canister_ids.json
├── wasm/
│   └── your-project.wasm.gz
├── your-project.did
└── .github/
    ├── workflows/
    ├── scripts/
    └── actions/
```

## 🔧 Available Commands

After installation, use these Makefile commands:

```bash
# Version management
make release-patch    # 0.1.0 → 0.1.1
make release-minor    # 0.1.0 → 0.2.0
make release-major    # 0.1.0 → 1.0.0

# Validation
make check-commits    # Check commit conventions
make check-version    # Verify version consistency

# Utilities
make help            # Show all available commands
```

## 🚨 Important Notes

### 1. Cargo.toml Version Handling

- **Workspace projects**: Version addition is skipped automatically
- **Package projects**: Version is added after `[package]` section
- **Other projects**: Version is added at the beginning

### 2. Changelog Management

- Starts empty with template structure
- Automatically populated from conventional commits
- Manual editing recommended before releases

### 3. Git Hook Behavior

- Validates conventional commit format
- Prevents commits that don't follow the pattern
- Can be bypassed with `git commit --no-verify` (not recommended)

### 4. GitHub Actions Triggers

- **CI/CD**: Triggers on push to master and pull requests
- **Release**: Triggers on version bumps
- **Manual Deploy**: Manual trigger for production deployment

## 🔄 Workflow Process

1. **Development**: Make conventional commits
2. **CI/CD**: Automated testing and dev deployment
3. **Release**: Version bump triggers release workflow
4. **Production**: Manual deployment when ready

## 🛠️ Troubleshooting

### Common Issues:

1. **Version not found**: Check Cargo.toml location and format
2. **Canister deployment fails**: Verify identity secrets and canister IDs
3. **NNS state issues**: Check network connectivity and cache settings
4. **Commit validation fails**: Ensure commits follow conventional format

### Debug Commands:

```bash
# Check version extraction
grep '^version = ' Cargo.toml

# Verify git hooks
ls -la .git/hooks/

# Test conventional commit
git commit -m "test: this should fail" --allow-empty

# Check GitHub Actions
gh run list
```

## 📚 Additional Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Internet Computer Documentation](https://internetcomputer.org/docs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## 🔗 Repository Links

- **Release System**: https://github.com/toolkit-development/release-system
- **Original Project**: https://github.com/toolkit-development/YOUR_CANISTER

---

**Last Updated**: August 5, 2025  
**Version**: 1.0.0  
**Status**: ✅ Production Ready
