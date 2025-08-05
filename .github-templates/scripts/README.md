# GitHub Actions Scripts

This folder contains scripts that are used by the GitHub Actions CI/CD workflows. These scripts automate various tasks in the build, test, and deployment pipeline.

**Location**: `.github/scripts/` - All GitHub-related files are kept together in the `.github/` directory.

## Scripts Overview

### 🔨 Build Scripts

#### `build.sh`

**Purpose**: Builds the user registry canister for deployment
**Usage**: `bash .github/scripts/build.sh`
**What it does**:

- Builds the canister using `dfx build`
- Generates the WASM file and Candid interface
- Creates the `canister_ids.json` file
- Outputs files to `wasm/` directory

**Used by**: CI, Deploy (dev/prod), and Release workflows

### 🧪 Test Scripts

#### `setup-nns-state.sh`

**Purpose**: Creates a local NNS (Network Nervous System) state for PocketIC testing
**Usage**: `bash .github/scripts/setup-nns-state.sh`
**What it does**:

- Sets up a temporary dfx project with NNS configuration
- Installs and configures NNS extension
- Creates a checkpoint of the NNS state
- Compresses the state into `src/test_helper/nns_state.tar.gz`
- Uses hardcoded NNS subnet key for reliability

**Used by**: CI workflow (test job)
**Dependencies**: Requires `dfx` and NNS extension

#### `extract-nns-state.sh`

**Purpose**: Extracts the compressed NNS state for testing
**Usage**: `bash .github/scripts/extract-nns-state.sh`
**What it does**:

- Extracts `nns_state.tar.gz` to `src/test_helper/nns_state/`
- Uses `--strip-components=1` to prevent nested directories
- Verifies successful extraction

**Used by**: CI workflow (test job)

### 📝 Release Scripts

#### `generate_changelog.sh`

**Purpose**: Generates a changelog based on conventional commits
**Usage**: `bash .github/scripts/generate_changelog.sh <version> <previous_tag>`
**What it does**:

- Parses git commits between the current version and previous tag
- Categorizes commits by type (feat, fix, docs, etc.)
- Generates a formatted changelog in `CHANGELOG.md`
- Supports conventional commit format

**Used by**: Deploy workflow (dev/prod)
**Example**: `bash .github/scripts/generate_changelog.sh "1.2.3" "v1.2.2"`

## Workflow Integration

### CI Workflow (`.github/workflows/ci.yml`)

- **Test Job**: Uses `setup-nns-state.sh` and `extract-nns-state.sh`
- **Build Job**: Uses `build.sh`

### Deploy Workflow (`.github/workflows/deploy.yml`)

- **Dev Job**: Uses `build.sh` and `generate_changelog.sh`
- **Prod Job**: Uses `build.sh`

### Release Workflow (`.github/workflows/release.yml`)

- **Release Job**: Uses `build.sh`

## Local Development

These scripts can also be used locally for development and testing:

```bash
# Build the canister locally
bash .github/scripts/build.sh

# Set up NNS state for local testing
bash .github/scripts/setup-nns-state.sh

# Extract NNS state for local testing
bash .github/scripts/extract-nns-state.sh

# Generate changelog for a new version
bash .github/scripts/generate_changelog.sh "1.2.3" "v1.2.2"
```

## Prerequisites

### For Build Scripts

- `dfx` (DFINITY Canister SDK)
- Rust toolchain with `wasm32-unknown-unknown` target

### For NNS Scripts

- `dfx` with NNS extension: `dfx extension install nns`
- Sufficient disk space for NNS state (~500MB)

### For Changelog Scripts

- Git repository with conventional commits
- `jq` for JSON processing

## Troubleshooting

### NNS State Issues

- **Timeout errors**: Increase timeout in `setup-nns-state.sh` (currently 30s)
- **Permission errors**: Ensure scripts are executable: `chmod +x .github/scripts/*.sh`
- **Cache issues**: Clear GitHub Actions cache or regenerate NNS state

### Build Issues

- **Missing dfx**: Install dfx: `sh -ci "$(curl -fsSL https://internetcomputer.org/install.sh)"`
- **Missing target**: Add WASM target: `rustup target add wasm32-unknown-unknown`

### Changelog Issues

- **Empty changelog**: Ensure commits follow conventional format
- **Missing tags**: Create git tags for previous versions

## File Structure

```
.github/scripts/
├── README.md              # This file
├── build.sh               # Build canister
├── setup-nns-state.sh     # Create NNS state
├── extract-nns-state.sh   # Extract NNS state
└── generate_changelog.sh  # Generate changelog
```

## Contributing

When adding new scripts to this folder:

1. **Update this README** with script description and usage
2. **Add proper error handling** and exit codes
3. **Include prerequisites** and dependencies
4. **Test locally** before updating workflows
5. **Update workflow files** to use the new script path

## Related Documentation

- [GitHub Actions Setup Guide](../../GITHUB_ACTIONS_SETUP.md)
- [Local CI/CD Scripts](../../scripts/run-*.sh) - For running workflows locally
- [Main Project README](../../README.md)
