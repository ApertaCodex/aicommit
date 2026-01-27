#!/usr/bin/env bats

load ../helpers/setup

@test "aicommit --no-push flag exists" {
  run /home/paradox/Workspace/projects/aicommit/aicommit --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--no-push" ]]
}

@test "aicommit --yes flag exists" {
  run /home/paradox/Workspace/projects/aicommit/aicommit --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--yes" ]]
}

@test "aicommit --changelog flag exists" {
  run /home/paradox/Workspace/projects/aicommit/aicommit --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--changelog" ]]
}

@test "aicommit --version flag exists" {
  run /home/paradox/Workspace/projects/aicommit/aicommit --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ "aicommit" || "$output" =~ "version" ]]
}

@test "aicommit -h shows help" {
  run /home/paradox/Workspace/projects/aicommit/aicommit -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Usage" ]]
}
