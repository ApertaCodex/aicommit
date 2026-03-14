# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Detect and update inline `VERSION="X.Y.Z"` in shell scripts and executables during release

## [1.9.0] - 2026-03-14

### Changed
- Update version to 1.8.1 (1a5e97b)

## [1.8.0] - 2026-03-14

### Added
- Version consolidation: detect and reconcile mismatched versions across project files during release (3b7c99c)

## [1.7.0] - 2026-02-13

### Added
- Show existing installation version during install (36446fd)

## [1.6.0] - 2026-02-13

### Added
- Enhanced version update process with support for more project file types (63e12ec)

### Security
- Harden repo with pinned GitHub Actions, least-privilege permissions, and security policy (8e1f5ee)

## [1.5.0] - 2026-02-13

### Added
- Author credit to README (ab5c2a8)

## [1.4.0] - 2026-02-13

### Added
- Version flag in help message (7ef7e08)

## [1.3.0] - 2026-02-13

### Added
- Auto-create initial tag when no version tags exist during release (3755946)
- Handle existing tags during release (a78efc1)

## [1.2.0] - 2026-02-13

### Added
- Create GitHub Release via gh CLI instead of relying on workflow (da9eba7)
- `--release` flag to post-install usage output (da6e3a2)

### Fixed
- Resolve shellcheck warnings and release workflow failure (e03c0cc)

### Changed
- Remove auto-release workflow and determine-version script (6308bc5)

## [1.1.0] - 2026-02-13
### Added
- add support for multiple AI providers (9ced39a)
- update command usage descriptions (13bf9c8)
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

