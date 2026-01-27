# aicommit

Generate conventional commit messages using AI.

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/apertacodex/aicommit/main/install.sh | bash
```

## Setup

Set your OpenAI API key:
```bash
export OPENAI_API_KEY='your-api-key-here'
echo 'export OPENAI_API_KEY="your-api-key-here"' >> ~/.bashrc
```

Install `jq`:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

## Usage

```bash
aicommit                    # Commit and push (default)
aicommit -n / --no-push     # Commit without pushing
aicommit -y / --yes         # Auto-accept generated message
aicommit -c / --changelog   # Update CHANGELOG.md with commit
aicommit -y -n              # Combine options
aicommit -c -y -n           # All options together

# Also works as a git command
git aicommit
```

The tool analyzes your git changes, generates a conventional commit message, and lets you review, edit, or abort before committing.

## CHANGELOG Integration

The `--changelog` (or `-c`) flag automatically updates `CHANGELOG.md` following the [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

### How it works

1. After committing your changes, the tool parses the commit message
2. Extracts the conventional commit type and description
3. Updates `CHANGELOG.md` with an entry in the "Unreleased" section
4. Amends the commit to include the changelog update

### Commit Type Mapping

| Commit Type | Changelog Section |
|-------------|-------------------|
| `feat`      | Added             |
| `fix`       | Fixed             |
| `docs`, `refactor`, `test`, `chore`, `style` | Changed |

### Entry Format

Each entry includes the commit description and short hash:
```markdown
- Add new user authentication feature (abc1234)
```

### Example

```bash
# Make some changes
echo "new feature" > feature.txt

# Commit with changelog update
aicommit --changelog

# Your CHANGELOG.md will automatically include:
# ## [Unreleased]
#
# ### Added
# - Add new user authentication feature (abc1234)
```

### Notes

- If `CHANGELOG.md` doesn't exist, it will be created with the standard template
- If `CHANGELOG.md` has uncommitted changes, the update is skipped (commit still succeeds)
- The changelog entry is added to the same commit (using `git commit --amend`)

## License

MIT
