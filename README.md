# Release System

A comprehensive release management system for Internet Computer canister projects with automated versioning, changelog generation, and deployment workflows.

## 🚀 Quick Start

### Install the Release System

```bash
# One-liner installation (latest version)
curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash

# Install specific version
curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/install.sh | bash -s -- --version v1.0.0

# Or download and run interactively
curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/master/setup.sh -o setup.sh
chmod +x setup.sh
./setup.sh
```

### Versioning

The release-system itself is versioned to ensure stability and allow users to install specific versions:

- **Latest**: Always installs the most recent version from `master` branch
- **Specific Version**: Install a particular version for stability (e.g., `v1.0.0`)
- **Changelog**: See [CHANGELOG.md](CHANGELOG.md) for detailed changes between versions

The setup script will:

- ✅ Detect your project name from the directory
- ✅ Customize all templates for your project
- ✅ Install GitHub Actions workflows
- ✅ Set up git hooks for commit validation
- ✅ Configure version management

### Create Your First Release

```bash
# Make some changes and commit them
git add .
git commit -m "feat: add new feature"

# Create a patch release
make release-patch
```

## 📁 What Gets Installed

The release system adds the following to your repository:

### Core Files

- **`Makefile`** - Automated release commands and version management
- **`RELEASE.md`** - Quick reference guide for releases
- **`CHANGELOG.md`** - Automated changelog generation
- **`.git/hooks/commit-msg`** - Enforces conventional commit format

### GitHub Actions Workflows

- **`.github/workflows/ci-cd.yml`** - Continuous integration and development deployment
- **`.github/workflows/release.yml`** - Automated releases from git tags
- **`.github/workflows/manual-deploy.yml`** - Manual production deployment

### Scripts and Actions

- **`.github/scripts/`** - Build, checksum, and changelog generation scripts
- **`.github/actions/`** - Reusable GitHub Actions for deployment and releases

## ⚙️ Required Configuration

### GitHub Secrets

After installation, configure these secrets in your GitHub repository:

**Required for Internet Computer deployment:**

- `IDENTITY_DEV` - PEM file content for development network deployment
- `IDENTITY_PROD` - PEM file content for production network deployment

**Deployment Flow:**

- **Development Identity (`IDENTITY_DEV`)**: Automatically deploys on every commit to main branch
- **Production Identity (`IDENTITY_PROD`)**: Manual deployment only (for safety)

**How to configure:**

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click 'New repository secret'
4. Add each secret with the appropriate value

**🔑 For Internet Computer deployment:**

- IDENTITY_DEV: Your development network identity PEM file content
- IDENTITY_PROD: Your production network identity PEM file content

## 🛠️ Available Commands

### Release Management

```bash
make release-patch    # 0.1.0 → 0.1.1 (bug fixes)
make release-minor    # 0.1.0 → 0.2.0 (new features)
make release-major    # 0.1.0 → 1.0.0 (breaking changes)
```

### Development Tools

```bash
make check-commits    # Check if commits follow conventions
make fix-commits      # Interactive rebase to fix commit messages
make add-changelog    # Add a new changelog entry
make generate-changelog-content  # Generate changelog from commits
```

### Help

```bash
make help            # Show all available commands
```

## 📝 Commit Message Format

All commits must follow the conventional commit format:

```
<type>: <description>

Examples:
feat: add user authentication
fix: resolve login timeout
docs: update API documentation
chore: update dependencies
```

### Supported Types

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks
- `ci:` - CI/CD changes
- `build:` - Build system changes
- `perf:` - Performance improvements
- `revert:` - Revert previous commits

## 🔄 Release Workflow

### Automated Release Process

1. **Make changes and commit with conventional format**

   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

2. **Create a release**

   ```bash
   make release-patch    # or release-minor, release-major
   ```

3. **Review and push**
   ```bash
   git add CHANGELOG.md
   git commit -m "docs: update changelog"
   git push origin main
   ```

### What Happens After Release

1. **GitHub Actions** automatically:

   - Builds the canister
   - Deploys to development network
   - Creates GitHub release
   - Uploads assets (WASM, Candid, checksums)

2. **Release assets** include:
   - `your-project.wasm.gz` - Compiled canister
   - `your-project.did` - Candid interface
   - `canister_ids.json` - Canister identifiers
   - Checksums for verification

## 🏗️ Project Structure

The system assumes this structure (customizable):

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

## 🔧 Customization

### Project-Specific Configuration

The setup script automatically customizes:

- All `YOUR_CANISTER` references → your project name
- File paths and package names
- GitHub Actions workflows
- Build and deployment scripts

### Manual Customization

Edit these files for project-specific needs:

- **`Makefile`** - Modify release commands and workflows
- **`.github/workflows/*.yml`** - Customize CI/CD pipelines
- **`.github/scripts/`** - Add project-specific scripts

## 🚨 Troubleshooting

### Common Issues

**"Commit message doesn't follow conventions"**

```bash
# Fix the last commit
git commit --amend -m "feat: correct commit message"

# Or use interactive fix
make fix-commits
```

**"Changelog not updating"**

```bash
# Manually add entry
make add-changelog

# Or regenerate content
make generate-changelog-content
```

**"Git push fails after rebase"**

```bash
# Force push (safely)
git push --force-with-lease origin main
```

**"Deployment fails"**

- Check GitHub secrets are configured
- Verify canister IDs in `canister_ids.json`
- Review GitHub Actions logs

### Debug Commands

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

## 🤝 Contributing

To contribute to the release system:

1. Fork the release-system repository
2. Make your changes
3. Test in a sample repository
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.

## 🆘 Support

For issues with the release system:

- Create an issue in the release-system repository
- Check existing issues for solutions
- Review the documentation in your repository's `RELEASE.md`

---

**Last Updated**: January 2025  
**Version**: 2.0.0  
**Status**: ✅ Production Ready
