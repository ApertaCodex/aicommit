#!/usr/bin/env bash
set -euo pipefail

# determine-version.sh
# Uses AI (OpenAI API) to analyze commits since the last tag and determine
# the appropriate semantic version bump (major, minor, or patch).
#
# Usage: ./scripts/determine-version.sh
# Requires: OPENAI_API_KEY environment variable
# Outputs: The next version string (e.g., "1.1.0") to stdout

if [[ -z "${OPENAI_API_KEY:-}" ]]; then
    echo "Error: OPENAI_API_KEY environment variable is not set." >&2
    exit 1
fi

if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed." >&2
    exit 1
fi

# Get the latest version tag
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")
if [[ -z "$LATEST_TAG" ]]; then
    echo "Error: No existing version tags found. Create an initial tag (e.g., v1.0.0) first." >&2
    exit 1
fi

CURRENT_VERSION="${LATEST_TAG#v}"

# Validate current version format
if ! [[ "$CURRENT_VERSION" =~ ^([0-9]+)\.([0-9]+)\.([0-9]+)$ ]]; then
    echo "Error: Latest tag '$LATEST_TAG' is not a valid semver format." >&2
    exit 1
fi

MAJOR="${BASH_REMATCH[1]}"
MINOR="${BASH_REMATCH[2]}"
PATCH="${BASH_REMATCH[3]}"

# Get commit messages since the last tag
COMMITS=$(git log "${LATEST_TAG}..HEAD" --pretty=format:"%s" 2>/dev/null)

if [[ -z "$COMMITS" ]]; then
    echo "Error: No new commits since ${LATEST_TAG}." >&2
    exit 1
fi

COMMIT_COUNT=$(echo "$COMMITS" | wc -l)
echo "Analyzing $COMMIT_COUNT commit(s) since ${LATEST_TAG}..." >&2

# Call OpenAI API to determine version bump
JSON_PAYLOAD=$(jq -n \
    --arg system "You are a semantic versioning assistant. You analyze git commit messages and determine the appropriate version bump according to Semantic Versioning (semver.org) and Conventional Commits.

Rules:
- MAJOR: commits with 'BREAKING CHANGE' in footer/body, or '!' after type/scope (e.g., 'feat!:', 'fix(api)!:')
- MINOR: commits with type 'feat' (new features)
- PATCH: commits with type 'fix', 'docs', 'style', 'refactor', 'perf', 'test', 'chore', or any other type

Respond with ONLY one word: major, minor, or patch. Nothing else." \
    --arg prompt "Analyze these commit messages and determine the version bump type:

$COMMITS

Current version: $CURRENT_VERSION

Respond with exactly one word: major, minor, or patch" \
    '{
        model: "gpt-4o-mini",
        messages: [
            {role: "system", content: $system},
            {role: "user", content: $prompt}
        ],
        temperature: 0,
        max_tokens: 10
    }')

RESPONSE=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d "$JSON_PAYLOAD")

if echo "$RESPONSE" | jq -e '.error' >/dev/null 2>&1; then
    ERROR_MSG=$(echo "$RESPONSE" | jq -r '.error.message')
    echo "Error from OpenAI API: $ERROR_MSG" >&2
    exit 1
fi

BUMP_TYPE=$(echo "$RESPONSE" | jq -r '.choices[0].message.content' | tr '[:upper:]' '[:lower:]' | tr -d '[:space:]')

# Validate response
if [[ "$BUMP_TYPE" != "major" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "patch" ]]; then
    echo "Error: Unexpected AI response: '$BUMP_TYPE'. Expected major, minor, or patch." >&2
    exit 1
fi

# Calculate next version
case "$BUMP_TYPE" in
    major) NEXT_VERSION="$((MAJOR + 1)).0.0" ;;
    minor) NEXT_VERSION="${MAJOR}.$((MINOR + 1)).0" ;;
    patch) NEXT_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))" ;;
esac

echo "Bump type: $BUMP_TYPE ($CURRENT_VERSION -> $NEXT_VERSION)" >&2
echo "$NEXT_VERSION"
