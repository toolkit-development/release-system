# Release Guide

Quick guide for creating releases in this repository.

## Quick Release

1. **Make changes and commit with conventional format:**

   ```bash
   git add .
   git commit -m "feat: add new feature"
   ```

2. **Create a release:**

   ```bash
   make release-patch    # 0.1.0 → 0.1.1
   make release-minor    # 0.1.0 → 0.2.0
   make release-major    # 0.1.0 → 1.0.0
   ```

3. **Review changelog and push:**
   ```bash
   git add CHANGELOG.md
   git commit -m "docs: update changelog"
   git push origin main
   ```

## Manual Release Process

1. **Check commit conventions:**

   ```bash
   make check-commits
   ```

2. **Fix any non-conventional commits:**

   ```bash
   make fix-commits
   ```

3. **Add changelog entry:**

   ```bash
   make add-changelog
   ```

4. **Create and push tag:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

## Commit Message Rules

All commits must follow this format:

```
<type>: <description>

Examples:
feat: add user authentication
fix: resolve login timeout
docs: update API documentation
chore: update dependencies
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

## Common Issues

**"Commit message doesn't follow conventions"**

- Use `make fix-commits` to rebase and fix
- Or amend the last commit: `git commit --amend -m "feat: correct message"`

**"Can't push after rebase"**

- Use: `git push --force-with-lease origin main`

**"Changelog not updating"**

- Run: `make add-changelog`
- Or: `make generate-changelog-content`

## What Happens After Release

1. GitHub Actions creates a release automatically
2. Assets are built and uploaded
3. Release notes are generated from changelog
4. Deployment to production (if configured)

## Need Help?

- Check the `Makefile` for all available commands
- Review GitHub Actions logs for deployment issues
- See the main README.md for detailed documentation
