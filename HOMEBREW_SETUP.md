# Homebrew Tap Setup Guide

This guide explains how to set up the Homebrew tap for aicommit to enable `brew install` functionality.

## Prerequisites

1. Create a GitHub Personal Access Token with `repo` permissions
2. Add the token as a GitHub Actions secret named `HOMEBREW_TAP_TOKEN`

## Step 1: Create Homebrew Tap Repository

1. Create a new GitHub repository: `homebrew-aicommit`
2. Initialize it with a README

## Step 2: Create Formula File

Create `Formula/aicommit.rb` in the `homebrew-aicommit` repository:

```ruby
class Aicommit < Formula
  desc "AI-powered conventional commit message generator"
  homepage "https://github.com/ApertaCodex/aicommit"
  url "https://github.com/ApertaCodex/aicommit/archive/v1.0.0.tar.gz"
  sha256 "PLACEHOLDER_SHA256"
  license "MIT"

  depends_on "jq"
  depends_on "curl"
  depends_on "git"

  def install
    bin.install "aicommit"
    bin.install_symlink "aicommit" => "git-aicommit"
  end

  test do
    system "#{bin}/aicommit", "--help"
  end
end
```

**Note**: The `url` and `sha256` will be automatically updated by the `update-homebrew.sh` script during releases.

## Step 3: Add Homebrew Job to Release Workflow

Add this job to `.github/workflows/release.yml`:

```yaml
  homebrew:
    name: Update Homebrew Formula
    needs: [build, github-release]
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Update Homebrew tap
        env:
          GH_TOKEN: ${{ secrets.HOMEBREW_TAP_TOKEN }}
        run: |
          chmod +x scripts/update-homebrew.sh
          git config --global url."https://x-access-token:${GH_TOKEN}@github.com/".insteadOf "https://github.com/"
          ./scripts/update-homebrew.sh ${{ needs.build.outputs.version }}
```

## Step 4: Configure GitHub Secrets

1. Go to your aicommit repository settings
2. Navigate to Secrets and Variables → Actions
3. Add a new secret:
   - Name: `HOMEBREW_TAP_TOKEN`
   - Value: Your GitHub Personal Access Token with `repo` permissions

## Step 5: Test Installation

After your first release with the Homebrew tap configured:

```bash
# Add the tap
brew tap apertacodex/aicommit

# Install aicommit
brew install aicommit

# Verify installation
aicommit --help
git aicommit --help
```

## Updating the Formula

The formula is automatically updated on each release by the `update-homebrew.sh` script, which:

1. Downloads the release tarball
2. Calculates its SHA256 checksum
3. Updates the formula file with the new URL and checksum
4. Commits and pushes the changes to the tap repository

## Troubleshooting

### Formula audit failures

Run `brew audit --strict --online apertacodex/aicommit/aicommit` to check for issues.

### Installation failures

1. Check that all dependencies (jq, curl, git) are available
2. Verify the tarball URL is accessible
3. Ensure the SHA256 checksum matches

### Token permission issues

Ensure the `HOMEBREW_TAP_TOKEN` has:
- `repo` scope (full repository access)
- Access to the `homebrew-aicommit` repository
