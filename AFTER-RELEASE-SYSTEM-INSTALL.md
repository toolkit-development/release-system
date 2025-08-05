# After Release System Installation Guide

This guide walks you through the essential steps to complete your release system setup and create your first release.

## 🎯 What Just Happened

The release system has been installed and customized for your project. Here's what was set up:

- ✅ **Git hooks** - Enforces conventional commit format
- ✅ **GitHub Actions workflows** - CI/CD, releases, and deployment
- ✅ **Makefile** - Automated release commands
- ✅ **Project customization** - All `YOUR_CANISTER` references updated to your project name

## 📋 Immediate Next Steps

### 1. **Configure GitHub Secrets** (Required)

Your deployment workflows need these secrets to function. You'll need **two separate identities**:

#### **Development Identity (`IDENTITY_DEV`)**

- **Purpose**: Automatic deployment on every commit to main branch
- **Network**: Development network (ic_testnet or local)
- **Frequency**: Every push to main branch

#### **Production Identity (`IDENTITY_PROD`)**

- **Purpose**: Manual deployment to production network
- **Network**: Internet Computer mainnet
- **Frequency**: Manual trigger only (for safety)

#### **How to Get Identity PEM Files**

1. **Create Development Identity:**

   ```bash
   # Create a new identity for development
   dfx identity new dev-identity
   dfx identity use dev-identity

   # Export the PEM file
   dfx identity export dev-identity > dev-identity.pem
   ```

2. **Create Production Identity:**

   ```bash
   # Create a new identity for production
   dfx identity new prod-identity
   dfx identity use prod-identity

   # Export the PEM file
   dfx identity export prod-identity > prod-identity.pem
   ```

3. **Get PEM Content:**
   ```bash
   # View the PEM content (copy this to GitHub secrets)
   cat dev-identity.pem
   cat prod-identity.pem
   ```

#### **Add to GitHub Secrets**

1. **Go to your GitHub repository**
2. **Navigate to Settings → Secrets and variables → Actions**
3. **Add these secrets:**

   **`IDENTITY_DEV`**

   - Content: Copy the entire content of `dev-identity.pem`
   - Used for: Automatic development deployments on every commit

   **`IDENTITY_PROD`**

   - Content: Copy the entire content of `prod-identity.pem`
   - Used for: Manual production deployments

### 2. **Verify Installation**

Check that all files were created correctly:

```bash
# Check core files
ls -la Makefile RELEASE.md CHANGELOG.md

# Check GitHub Actions
ls -la .github/workflows/
ls -la .github/scripts/

# Check git hooks
ls -la .git/hooks/commit-msg
```

### 3. **Test Commit Validation**

Verify the git hook is working:

```bash
# This should fail (no conventional format)
git commit -m "test commit" --allow-empty

# This should succeed
git commit -m "feat: add release system" --allow-empty
```

## 🚀 Create Your First Release

### Step 1: Make Some Changes

```bash
# Add the release system files
git add .

# Commit with conventional format
git commit -m "feat: add release system"

# Push to remote
git push origin main
```

### Step 2: Create a Release

```bash
# Create a patch release (0.1.0 → 0.1.1)
make release-patch

# Or create a minor release (0.1.0 → 0.2.0)
make release-minor

# Or create a major release (0.1.0 → 1.0.0)
make release-major
```

### Step 3: Review and Push

```bash
# Review the changelog
cat CHANGELOG.md

# Add and commit changelog updates
git add CHANGELOG.md
git commit -m "docs: update changelog"

# Push to trigger the release
git push origin main
```

## 🔧 Project-Specific Configuration

### Update Project Structure

Ensure your project matches the expected structure:

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

### Update Canister Configuration

1. **Update `canister_ids.json`:**

   ```json
   {
     "YOUR_CANISTER": {
       "ic": "your-production-canister-id",
       "dev": "your-development-canister-id"
     }
   }
   ```

2. **Update Cargo.toml version:**
   ```toml
   [package]
   name = "YOUR_CANISTER"
   version = "0.1.0"
   ```

### Customize Build Scripts

Edit `.github/scripts/build.sh` if your build process differs:

```bash
# Default build command
cargo build -p YOUR_CANISTER --release --target wasm32-unknown-unknown

# Customize for your specific needs
```

## 🔄 Deployment Flow

### **Development Deployment (Automatic)**

- **Trigger**: Every push to main branch
- **Network**: Development network (ic_testnet)
- **Identity**: `IDENTITY_DEV` secret
- **Purpose**: Test changes before production

### **Production Deployment (Manual)**

- **Trigger**: Manual workflow trigger
- **Network**: Internet Computer mainnet
- **Identity**: `IDENTITY_PROD` secret
- **Purpose**: Deploy to production when ready

### **How to Deploy to Production**

1. **Go to GitHub Actions tab**
2. **Select "Manual Deploy" workflow**
3. **Click "Run workflow"**
4. **Select branch and click "Run workflow"**

This ensures production deployments are intentional and controlled.

## 📝 Available Commands

### Release Management

```bash
make release-patch    # 0.1.0 → 0.1.1
make release-minor    # 0.1.0 → 0.2.0
make release-major    # 0.1.0 → 1.0.0
```

### Development Tools

```bash
make check-commits    # Validate commit format
make fix-commits      # Interactive rebase to fix commits
make add-changelog    # Add changelog entry
make help            # Show all commands
```

### Manual Release Process

```bash
# 1. Check commits
make check-commits

# 2. Add changelog entry
make add-changelog

# 3. Create and push tag
git tag v1.0.0
git push origin v1.0.0
```

## 🔍 Troubleshooting

### Common Issues

**"Commit message doesn't follow conventions"**

```bash
# Fix the last commit
git commit --amend -m "feat: correct message"

# Or use interactive fix
make fix-commits
```

**"GitHub Actions failing"**

- Check GitHub secrets are configured
- Verify canister IDs in `canister_ids.json`
- Review Actions logs for specific errors

**"Deployment fails"**

- Ensure identity PEM files are correct
- Check network connectivity
- Verify canister exists and is accessible

**"Version not found"**

```bash
# Check Cargo.toml location and format
grep '^version = ' Cargo.toml
# or
grep '^version = ' src/YOUR_CANISTER/Cargo.toml
```

**"Identity authentication fails"**

```bash
# Verify PEM file format
cat your-identity.pem | head -5

# Should start with: -----BEGIN PRIVATE KEY-----
# Should end with: -----END PRIVATE KEY-----

# Test identity locally
dfx identity use your-identity
dfx ping
```

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

# Verify identity files
dfx identity list
dfx identity whoami
```

## 📚 Documentation

### Quick References

- **`RELEASE.md`** - Release process guide
- **`CHANGELOG.md`** - Project changelog
- **`Makefile`** - All available commands

### External Resources

- [Conventional Commits](https://www.conventionalcommits.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [Internet Computer Docs](https://internetcomputer.org/docs/)
- [DFX Identity Management](https://internetcomputer.org/docs/current/developer-docs/setup/dfx/manage-identities)

## 🎉 Success Checklist

- [ ] GitHub secrets configured (`IDENTITY_DEV`, `IDENTITY_PROD`)
- [ ] Project structure matches expectations
- [ ] `canister_ids.json` updated with your canister IDs
- [ ] Git hooks working (conventional commits enforced)
- [ ] First commit with conventional format successful
- [ ] First release created and pushed
- [ ] GitHub Actions workflows running successfully
- [ ] Development deployment working (automatic on commits)
- [ ] Production deployment working (manual trigger)
- [ ] Release assets being generated

## 🆘 Need Help?

1. **Check the logs** - Review GitHub Actions logs for specific errors
2. **Review documentation** - See `RELEASE.md` for detailed usage
3. **Test incrementally** - Start with simple commits, then releases, then deployments
4. **Check prerequisites** - Ensure all tools are installed and configured
5. **Verify identities** - Test identity authentication locally before adding to secrets

---

**Remember**: The release system is designed to make your development workflow smoother. Start with simple releases and gradually explore more advanced features as you become comfortable with the system.

**Security Note**: Keep your production identity secure and never commit PEM files to your repository. Only use them as GitHub secrets.
