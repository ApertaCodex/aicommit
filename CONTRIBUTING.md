# Contributing to aicommit

Thank you for considering contributing to aicommit! This document outlines the development workflow and guidelines.

## Development Setup

### Prerequisites

- Git
- Bash (4.0+)
- jq
- curl
- shellcheck (for linting)
- BATS (for testing)

### Setting Up Your Environment

1. Fork and clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/aicommit.git
   cd aicommit
   ```

2. Install dependencies:
   ```bash
   # Ubuntu/Debian
   sudo apt-get install jq curl git shellcheck

   # macOS
   brew install jq curl git shellcheck
   ```

3. Install BATS for testing:
   ```bash
   git clone https://github.com/bats-core/bats-core.git /tmp/bats-core
   cd /tmp/bats-core && sudo ./install.sh /usr/local
   ```

4. Install the tool locally:
   ```bash
   ./install.sh
   ```

## Development Workflow

### Making Changes

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes to the codebase

3. Run linter:
   ```bash
   shellcheck aicommit install.sh scripts/*.sh
   ```

4. Run tests:
   ```bash
   ./tests/run-tests.sh
   ```

5. Update documentation if needed (README.md, comments in code)

6. Update CHANGELOG.md under the `[Unreleased]` section

### Commit Messages

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `test:` Test additions or modifications
- `chore:` Maintenance tasks
- `refactor:` Code refactoring
- `style:` Code style changes (formatting, etc.)
- `perf:` Performance improvements

**Examples:**
```
feat(changelog): add support for security section
fix(api): handle rate limiting errors gracefully
docs(readme): update installation instructions
test(commit): add tests for --no-push flag
```

### Pull Request Process

1. Update the CHANGELOG.md with your changes under `[Unreleased]`
2. Ensure all tests pass locally
3. Push your branch to your fork
4. Open a Pull Request against the `main` branch
5. Fill out the PR template with:
   - Description of changes
   - Related issues (if any)
   - Testing performed
6. Wait for CI checks to pass
7. Address any review feedback
8. Once approved, a maintainer will merge your PR

### Code Style Guidelines

- Use 2 spaces for indentation
- Follow existing code patterns and conventions
- Add comments for complex logic
- Keep functions small and focused
- Use meaningful variable names
- Quote all variables to prevent word splitting
- Use `set -euo pipefail` at the start of scripts

### Testing Guidelines

- Write tests for new features
- Update existing tests if behavior changes
- Test both success and failure cases
- Use descriptive test names
- Mock external dependencies (API calls, etc.)

### Adding New Features

1. Check existing issues or create one to discuss the feature
2. Get maintainer feedback before starting large changes
3. Follow the development workflow above
4. Document the feature in README.md
5. Add tests for the new functionality
6. Update CHANGELOG.md

## Release Process (Maintainers Only)

Releases are automated through GitHub Actions when a version tag is pushed.

### Creating a Release

1. Ensure all desired changes are merged to `main`

2. Update CHANGELOG.md:
   - Add entries under `[Unreleased]` section
   - Use standard sections: Added, Changed, Deprecated, Removed, Fixed, Security

3. Validate CHANGELOG:
   ```bash
   ./scripts/validate-changelog.sh
   ```

4. Create and push the release tag:
   ```bash
   ./scripts/release.sh v1.2.3
   ```

5. GitHub Actions will automatically:
   - Update CHANGELOG.md (move Unreleased to versioned section)
   - Create GitHub release with release notes
   - Build and upload packages (deb, rpm)
   - Generate checksums
   - Update Homebrew formula

6. Verify the release:
   - Check GitHub releases page
   - Test package installations
   - Verify Homebrew formula update

### Version Numbering

We follow [Semantic Versioning](https://semver.org/):

- `MAJOR.MINOR.PATCH` format
- MAJOR: Breaking changes
- MINOR: New features (backwards compatible)
- PATCH: Bug fixes (backwards compatible)

## Project Structure

```
aicommit/
├── aicommit                    # Main script
├── install.sh                  # Installation script
├── README.md                   # User documentation
├── CHANGELOG.md                # Version history
├── CONTRIBUTING.md             # This file
├── LICENSE                     # MIT license
├── .shellcheckrc               # Shellcheck configuration
├── .github/
│   └── workflows/
│       ├── ci.yml              # CI pipeline
│       └── release.yml         # Release automation
├── scripts/
│   ├── validate-changelog.sh  # CHANGELOG validation
│   ├── prepare-release.sh     # Release preparation
│   ├── extract-release-notes.sh
│   ├── release.sh              # Release creation
│   ├── build-deb.sh            # Debian package builder
│   ├── build-rpm.sh            # RPM package builder
│   └── update-homebrew.sh     # Homebrew formula updater
└── tests/
    ├── run-tests.sh            # Test runner
    ├── helpers/
    │   └── setup.bash          # Test helpers
    └── integration/
        ├── test_basic_commit.bats
        ├── test_flags.bats
        └── test_changelog.bats
```

## Getting Help

- Open an issue for bugs or feature requests
- Check existing issues before creating new ones
- Ask questions in issue discussions
- Review closed issues for similar problems

## Code of Conduct

- Be respectful and inclusive
- Provide constructive feedback
- Focus on the code, not the person
- Help create a welcoming environment

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
