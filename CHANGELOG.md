# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- remove banner display from main flow (cf8e79e)

## [1.0.3] - 2026-02-12

### Fixed
- Installation script now supports piped execution from curl (curl | bash)
- BASH_SOURCE handling for remote installations
- Automatic download of aicommit from GitHub during piped install

## [1.0.2] - 2026-01-27
### Fixed
- Duplicate entries in CHANGELOG when creating releases
- prepare-release.sh not clearing [Unreleased] section after moving content

### Added
- Complete CI/CD infrastructure with GitHub Actions
- Automated testing with BATS framework (12 integration tests)
- Shellcheck linting on every PR and push
- Multi-platform package building (Debian .deb and Red Hat .rpm)
- Automated release workflow triggered by version tags
- Homebrew tap support and setup guide
- Multiple installation methods (curl, brew, deb, rpm, from source)
- CHANGELOG automation and validation
- Comprehensive test suite covering all flags and functionality
- Development and contribution guides

### Changed
- Updated README with installation methods and development guide
- Improved test infrastructure with dynamic project root detection

### Fixed
- GitHub Actions workflow failures (shellcheck, test paths, install validation)
- Hardcoded paths in tests for CI compatibility

