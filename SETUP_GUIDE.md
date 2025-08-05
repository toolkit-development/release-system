# Setting Up the Release System Repository

This guide explains how to set up the release system repository that other projects can use.

## Repository Structure

```
release-system/
├── README.md              # Main documentation
├── setup.sh               # Main setup script
├── install.sh             # One-liner installer
├── test-setup.sh          # Test script
├── LICENSE                # MIT License
├── SETUP_GUIDE.md         # This file
└── templates/             # Template files (optional)
    ├── Makefile
    ├── RELEASE.md
    └── CHANGELOG.md
```

## Setup Steps

### 1. Create the Repository

```bash
# Create a new repository on GitHub
# Name: release-system
# Description: Comprehensive release management system for GitHub repositories
# Visibility: Public
# License: MIT
```

### 2. Clone and Initialize

```bash
git clone https://github.com/toolkit-development/release-system.git
cd release-system
```

### 3. Add Files

Copy all the files from the `release-system-setup/` directory:

```bash
# Copy the setup files
cp -r release-system-setup/* .

# Make scripts executable
chmod +x setup.sh install.sh test-setup.sh
```

### 4. Test the Setup

```bash
# Run the test script to verify everything works
./test-setup.sh
```

### 5. Commit and Push

```bash
git add .
git commit -m "feat: initial release system setup"
git push origin main
```

## Usage by Other Repositories

Once the repository is set up, other repositories can install the release system with:

```bash
# One-liner installation
curl -fsSL https://raw.githubusercontent.com/toolkit-development/release-system/main/install.sh | bash
```

## Updating the Release System

When you make changes to the release system:

1. **Update the files** in your local repository
2. **Test the changes** using `./test-setup.sh`
3. **Commit and push** the changes
4. **Create a release** with a new version tag

## Version Management

The release system itself should follow semantic versioning:

- **Patch releases** (0.1.0 → 0.1.1): Bug fixes and minor improvements
- **Minor releases** (0.1.0 → 0.2.0): New features, backward compatible
- **Major releases** (1.0.0 → 2.0.0): Breaking changes

## Distribution Strategy

The release system uses a **template-based approach**:

1. **Primary method**: Download files from the repository
2. **Fallback method**: Create files from embedded templates
3. **Git hooks**: Created locally during installation

This ensures:

- ✅ **Reliability**: Works even if GitHub is down
- ✅ **Flexibility**: Easy to customize for different projects
- ✅ **Maintainability**: Single source of truth

## Security Considerations

- All scripts are open source and can be reviewed
- No external dependencies beyond standard Unix tools
- Git hooks are created locally and can be modified
- No automatic execution of downloaded code

## Support and Maintenance

- **Issues**: Use GitHub Issues for bug reports and feature requests
- **Documentation**: Keep README.md and RELEASE.md up to date
- **Testing**: Run `./test-setup.sh` before each release
- **Backward compatibility**: Maintain compatibility with existing installations

## Future Enhancements

Potential improvements:

- [ ] Support for different project types (Node.js, Python, etc.)
- [ ] Customizable workflows and actions
- [ ] Integration with package managers
- [ ] Web-based configuration interface
- [ ] Plugin system for extensions
