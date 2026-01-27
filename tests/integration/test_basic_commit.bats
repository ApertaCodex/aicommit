#!/usr/bin/env bats

load ../helpers/setup

# Get the path to the aicommit script
AICOMMIT_SCRIPT="${BATS_TEST_DIRNAME}/../../aicommit"

setup() {
  setup_test_repo
  setup_git_config
}

teardown() {
  teardown_test_repo
}

@test "aicommit --help shows options" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Options:" ]]
  [[ "$output" =~ "--changelog" ]]
}

@test "aicommit shows help without git repo" {
  cd /tmp || exit 1
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Options:" ]]
}

@test "aicommit processes empty repository" {
  export OPENAI_API_KEY="test-key"
  run "$AICOMMIT_SCRIPT" --yes --no-push
  # Script will try to analyze even with no changes (due to header always present)
  # With invalid API key, it will fail gracefully
  [[ "$output" =~ "Analyzing changes" ]]
}

@test "aicommit requires OPENAI_API_KEY for commit" {
  unset OPENAI_API_KEY
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "OPENAI_API_KEY" ]]
}
