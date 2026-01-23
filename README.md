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
aicommit -y -n              # Combine options

# Also works as a git command
git aicommit
```

The tool analyzes your git changes, generates a conventional commit message, and lets you review, edit, or abort before committing.

## License

MIT
