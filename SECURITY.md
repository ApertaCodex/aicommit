# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.5.x   | :white_check_mark: |
| < 1.5   | :x:                |

## Reporting a Vulnerability

If you discover a security vulnerability, please report it responsibly:

1. **Do NOT open a public issue.**
2. Email **security@moussamokhtari.com** with details of the vulnerability.
3. Include steps to reproduce, potential impact, and any suggested fixes.

We will acknowledge receipt within 48 hours and aim to provide a fix within 7 days for critical issues.

## Security Practices

- API keys are stored locally in `~/.aicommit/config` and never transmitted except to the configured AI provider.
- No telemetry or analytics data is collected.
- All AI provider communication uses HTTPS.
- GitHub Actions workflows use pinned SHA hashes to prevent supply-chain attacks.
