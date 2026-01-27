#!/usr/bin/env bats

load ../helpers/setup

setup() {
  setup_test_repo
  setup_git_config
}

teardown() {
  teardown_test_repo
}

@test "aicommit --help shows usage" {
  run /home/paradox/Workspace/projects/aicommit/aicommit --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage" ]]
  [[ "$output" =~ "--changelog" ]]
}

@test "aicommit shows help without git repo" {
  cd /tmp || exit 1
  run /home/paradox/Workspace/projects/aicommit/aicommit --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage" ]]
}

@test "aicommit detects no changes" {
  export OPENAI_API_KEY="test-key"
  run /home/paradox/Workspace/projects/aicommit/aicommit --yes --no-push
  [ "$status" -eq 0 ]
  [[ "$output" =~ "No changes" || "$output" =~ "nothing to commit" ]]
}

@test "aicommit requires OPENAI_API_KEY for commit" {
  unset OPENAI_API_KEY
  echo "test" > test.txt
  git add test.txt
  run /home/paradox/Workspace/projects/aicommit/aicommit --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "OPENAI_API_KEY" ]]
}
