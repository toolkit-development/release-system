# Changelog

All notable changes to the Release System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Version management system for the release-system repository
- Support for installing specific versions via `--version` flag
- Version management script (`scripts/version.sh`)
- Release workflow for the release-system repository
- VERSION file for tracking current version

### Changed
- Enhanced install script with version support
- Updated setup script to support versioned downloads
- Improved error handling for version-specific installations

### Fixed
- Fixed YOUR_CANISTER replacement in bump_version.sh
- Fixed Candid file path in checksum creation scripts
- Enhanced script permission handling during setup

## [1.0.0] - 2025-01-06

### Added
- Complete release management system for Rust canister projects
- Automated version bumping with semantic versioning
- Conventional commit validation
- GitHub Actions workflows for CI/CD
- Automated release creation with assets
- Changelog generation from git commits
- NNS state management for testing
- Comprehensive documentation and setup guides

### Features
- `make release-patch` - Create patch releases (0.1.0 → 0.1.1)
- `make release-minor` - Create minor releases (0.1.0 → 0.2.0)  
- `make release-major` - Create major releases (0.1.0 → 1.0.0)
- `make generate-changelog-content` - Generate changelog from commits
- `make check-commits` - Validate commit message format
- Automated deployment to development and production networks
- WASM compilation and checksum generation
- Release asset management (WASM, Candid, checksums)

### Documentation
- Comprehensive README with setup instructions
- AFTER-RELEASE-SYSTEM-INSTALL.md for post-installation steps
- RELEASE.md for detailed usage instructions
- SETUP_REFERENCE.md for configuration details
