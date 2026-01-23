# AI Commit

Automatically generate Conventional Commit messages using OpenAI's GPT-4o-mini model.

## Features

- Generates commit messages following the [Conventional Commits](https://www.conventionalcommits.org/) specification
- Analyzes staged, unstaged, and untracked changes
- Allows review and editing before committing
- Optionally pushes to remote repository
- Handles large diffs intelligently with truncation

## Prerequisites

- Git installed
- `jq` command-line JSON processor
- OpenAI API key

### Installing jq

**Ubuntu/Debian:**
```bash
sudo apt-get install jq
```

**macOS:**
```bash
brew install jq
```

**Arch Linux:**
```bash
sudo pacman -S jq
```

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/apertacodex/aicommit/main/install.sh | bash
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/apertacodex/aicommit.git
cd aicommit
```

2. Run the install script:
```bash
./install.sh
```

Or manually copy the script:
```bash
sudo cp aicommit /usr/local/bin/aicommit
sudo chmod +x /usr/local/bin/aicommit
```

3. Set up your OpenAI API key:
```bash
export OPENAI_API_KEY='your-api-key-here'
```

Add this to your `~/.bashrc`, `~/.zshrc`, or `~/.profile` to make it permanent:
```bash
echo 'export OPENAI_API_KEY="your-api-key-here"' >> ~/.bashrc
```

## Usage

### Basic Usage

Commit and push changes:
```bash
git aicommit
```

Or simply:
```bash
aicommit
```

### Options

**Commit without pushing:**
```bash
aicommit --no-push
# or
aicommit -n
```

**Non-interactive mode (auto-accept generated message):**
```bash
aicommit --yes
# or
aicommit -y
```

**Combine options:**
```bash
aicommit -y -n
```

**Show help:**
```bash
aicommit --help
```

## How It Works

1. Analyzes your git changes (staged, unstaged, and untracked files)
2. Sends the diff to OpenAI's GPT-4o-mini model
3. Generates a Conventional Commit message with:
   - Type: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, or `chore`
   - Scope: (when applicable)
   - Description: concise summary under 50 characters
   - Body: bullet points with details
4. Displays the generated message for review
5. Allows you to use, edit, or abort
6. Commits with `git add -A` and `git commit`
7. Optionally pushes to remote repository

## Interactive Workflow

After generating a commit message, you'll see:

```
AI‑generated commit message:
--------------------------------
feat(api): add user authentication endpoint

- Implement JWT token generation
- Add login and logout routes
- Create user validation middleware
--------------------------------
Use this commit message? [Y/n/e] (Y = use, n = abort, e = edit):
```

Options:
- `Y` or Enter: Use the generated message
- `n`: Abort the commit
- `e`: Edit the message in your default editor

## Configuration

### Character Limits

The script has built-in limits to avoid exceeding OpenAI token limits:
- `MAX_CHAR_LIMIT=20000`: Total character limit for all changes
- `MAX_FILE_CHAR_LIMIT=2000`: Character limit per file content
- `MAX_DIFF_LINES=100`: Maximum diff lines per file

These can be adjusted in the script if needed.

### OpenAI Model

By default, the script uses `gpt-4o-mini`. You can modify the model in the script by changing line 205:
```json
model: "gpt-4o-mini"
```

## Troubleshooting

### Error: OPENAI_API_KEY not set

Make sure you've exported your API key:
```bash
export OPENAI_API_KEY='your-api-key-here'
```

### Error: jq not installed

Install jq using your package manager (see Prerequisites section).

### Error: The diff is too large

The changes exceed the token limit. Either:
- Commit changes in smaller chunks
- Adjust `MAX_CHAR_LIMIT` in the script

### Error: Not inside a git repository

Run the command from within a git repository.

## License

MIT License - see LICENSE file for details

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Credits

Created to automate the generation of high-quality commit messages following industry best practices.
