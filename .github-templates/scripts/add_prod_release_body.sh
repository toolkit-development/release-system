#!/bin/bash

# Add production release body generation step to the workflow
# This script inserts the release body generation step before the Create Production Release step

WORKFLOW_FILE=".github/workflows/manual-deploy.yml"

# Find the line number of "Create Production Release"
LINE_NUM=$(grep -n "Create Production Release" "$WORKFLOW_FILE" | cut -d: -f1)

if [ -z "$LINE_NUM" ]; then
    echo "❌ Could not find 'Create Production Release' step"
    exit 1
fi

echo "📝 Adding production release body generation step before line $LINE_NUM..."

# Create temporary file with the new content
TEMP_FILE=$(mktemp)

# Copy lines before the target line
head -n $((LINE_NUM - 1)) "$WORKFLOW_FILE" > "$TEMP_FILE"

# Add the release body generation step
cat >> "$TEMP_FILE" << 'EOF'
      - name: Generate release body
        id: release_body
        run: |
          # Extract changelog content for the current version
          CHANGELOG_CONTENT=""
          if [ -f "CHANGELOG.md" ]; then
            CHANGELOG_CONTENT=$(cat CHANGELOG.md | sed -n '/^## \[/,$p' | head -n 50)
          fi
          
          # Create release body
          RELEASE_BODY="Production deployment successful

          Version: ${{ needs.get-version.outputs.version }}
          Commit: ${{ github.sha }}

          This is an automated production release.

          ## Changelog
          $CHANGELOG_CONTENT"
          
          # Escape newlines for GitHub Actions
          RELEASE_BODY="${RELEASE_BODY//'%'/'%25'}"
          RELEASE_BODY="${RELEASE_BODY//$'\n'/'%0A'}"
          RELEASE_BODY="${RELEASE_BODY//$'\r'/'%0D'}"
          
          echo "release_body=$RELEASE_BODY" >> $GITHUB_OUTPUT

EOF

# Copy the rest of the file
tail -n +$LINE_NUM "$WORKFLOW_FILE" >> "$TEMP_FILE"

# Replace the original file
mv "$TEMP_FILE" "$WORKFLOW_FILE"

echo "✅ Production release body generation step added successfully" 