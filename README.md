# Release System Setup

A comprehensive release management system for GitHub repositories with automated versioning, changelog generation, and deployment workflows.

## Quick Start

### 1. Install the Release System

```bash
# Download and run the setup script
curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/main/setup.sh | bash
```

### 2. Initialize in Your Repository

```bash
# Navigate to your repository
cd your-repo

# Run the setup
./setup-release-system.sh
```

### 3. Create Your First Release

```bash
# Make some changes and commit them
git add .
git commit -m "feat: add new feature"

# Create a patch release
make release-patch
```

## What Gets Installed

The release system adds the following to your repository:

### Core Files

- **`Makefile`** - Automated release commands
- **`RELEASE.md`** - Release guide for contributors
- **`CHANGELOG.md`** - Automated changelog generation
- **`.git/hooks/commit-msg`** - Enforces conventional commit format

### GitHub Actions

- **`.github/workflows/ci-cd.yml`** - Continuous integration and dev deployment
- **`.github/workflows/release.yml`** - Automated releases from tags
- **`.github/workflows/manual-deploy.yml`** - Manual production deployment

### Scripts

- **`.github/scripts/`** - Build and deployment scripts
- **`.github/actions/`** - Reusable GitHub Actions

## Available Commands

### Release Commands

```bash
make release-patch    # Bump patch version (0.1.0 → 0.1.1)
make release-minor    # Bump minor version (0.1.0 → 0.2.0)
make release-major    # Bump major version (0.1.0 → 1.0.0)
```

### Development Commands

```bash
make check-commits    # Check if commits follow conventions
make fix-commits      # Interactive rebase to fix commit messages
make add-changelog    # Add a new changelog entry
```

### Quality Assurance

```bash
make lint            # Run linting checks
make test            # Run tests
make security        # Run security checks
```

## Commit Message Format

All commits must follow the conventional commit format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

### Examples

```bash
git commit -m "feat: add user authentication"
git commit -m "fix: resolve login timeout issue"
git commit -m "docs: update API documentation"
git commit -m "chore: update dependencies"
```

## Release Workflow

### Automated Release

1. Make changes and commit with conventional format
2. Run `make release-patch` (or minor/major)
3. Review changelog and commit if needed
4. Push tag to trigger GitHub release

### Manual Release

1. Create a tag: `git tag v1.0.0`
2. Push tag: `git push origin v1.0.0`
3. GitHub Actions will create the release automatically

## Configuration

### Customizing the Release System

Edit the following files to customize for your project:

- **`Makefile`** - Modify release commands and workflows
- **`.github/workflows/*.yml`** - Customize CI/CD pipelines
- **`scripts/`** - Add project-specific scripts

### Environment Variables

Set these in your GitHub repository settings:

- `DFX_NETWORK` - Internet Computer network (ic, ic_testnet)
- `CANISTER_ID` - Your canister ID for deployment
- `GITHUB_TOKEN` - For creating releases (auto-set by GitHub Actions)

## Troubleshooting

### Common Issues

**"Commit message doesn't follow conventions"**

```bash
# Fix the last commit
git commit --amend -m "feat: correct commit message"

# Or use the interactive fix
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

### Getting Help

1. Check the `RELEASE.md` file in your repository
2. Review the `Makefile` for available commands
3. Check GitHub Actions logs for deployment issues

## Contributing

To contribute to the release system itself:

1. Fork the release-system repository
2. Make your changes
3. Test in a sample repository
4. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Support

For issues with the release system:

- Create an issue in the release-system repository
- Check existing issues for solutions
- Review the documentation in your repository's `RELEASE.md`
