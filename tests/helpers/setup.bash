# Common test setup functions for aicommit tests

# Get the project root directory (where CHANGELOG.md should be)
get_project_root() {
  # This assumes the test is being run from the project directory
  # or that BATS_TEST_DIRNAME is set (which BATS sets automatically)
  if [ -n "${BATS_TEST_DIRNAME:-}" ]; then
    echo "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"
  else
    pwd
  fi
}

# Setup a temporary git repository for testing
setup_test_repo() {
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR" || exit 1
  git init
  git config user.name "Test User"
  git config user.email "test@example.com"
}

# Cleanup test repository
teardown_test_repo() {
  if [ -n "$TEST_DIR" ] && [ -d "$TEST_DIR" ]; then
    cd / || exit 1
    rm -rf "$TEST_DIR"
  fi
}

# Mock OpenAI API response for testing
mock_openai_response() {
  cat << 'EOF'
feat(test): add test feature

- Implement test functionality
- Add test documentation
EOF
}

# Setup minimal git configuration
setup_git_config() {
  git config --global user.name "Test User" 2>/dev/null || true
  git config --global user.email "test@example.com" 2>/dev/null || true
}
