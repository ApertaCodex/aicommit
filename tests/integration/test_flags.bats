#!/usr/bin/env bats

load ../helpers/setup

# Get the path to the aicommit script
AICOMMIT_SCRIPT="${BATS_TEST_DIRNAME}/../../aicommit"

@test "aicommit --no-push flag exists" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--no-push" ]]
}

@test "aicommit --yes flag exists" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--yes" ]]
}

@test "aicommit --changelog flag exists" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--changelog" ]]
}

@test "aicommit --provider flag exists" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--provider" ]]
}

@test "aicommit -h shows help" {
  run "$AICOMMIT_SCRIPT" -h
  [ "$status" -eq 0 ]
  [[ "$output" =~ "Options:" ]]
}

@test "aicommit help shows all flags" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "-n" ]]
  [[ "$output" =~ "-y" ]]
  [[ "$output" =~ "-c" ]]
  [[ "$output" =~ "-p" ]]
  [[ "$output" =~ "-r" ]]
  [[ "$output" =~ "-h" ]]
}

@test "aicommit --release flag exists" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--release" ]]
}

@test "aicommit -r flag exists in help" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "-r" ]]
}

@test "aicommit help lists supported providers" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "openai" ]]
  [[ "$output" =~ "anthropic" ]]
  [[ "$output" =~ "gemini" ]]
  [[ "$output" =~ "groq" ]]
  [[ "$output" =~ "ollama" ]]
  [[ "$output" =~ "custom" ]]
}
