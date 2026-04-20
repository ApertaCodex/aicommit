#!/usr/bin/env bats

load ../helpers/setup

AICOMMIT_SCRIPT="${BATS_TEST_DIRNAME}/../../aicommit"

setup() {
  setup_test_repo
  setup_git_config
  # Clear all provider env vars
  unset OPENAI_API_KEY
  unset ANTHROPIC_API_KEY
  unset GEMINI_API_KEY
  unset GROQ_API_KEY
  unset AICOMMIT_PROVIDER
  unset AICOMMIT_OPENAI_MODEL
  unset AICOMMIT_ANTHROPIC_MODEL
  unset AICOMMIT_GEMINI_MODEL
  unset AICOMMIT_GROQ_MODEL
  unset AICOMMIT_OLLAMA_MODEL
  unset AICOMMIT_CUSTOM_MODEL
  unset AICOMMIT_CUSTOM_API_URL
  unset AICOMMIT_CUSTOM_API_KEY
  rm -f "$HOME/.aicommitrc"
  # Restrict PATH to exclude ollama for deterministic provider tests
  export PATH="/usr/bin:/bin"
}

teardown() {
  teardown_test_repo
  rm -f "$HOME/.aicommitrc"
}

@test "provider flag rejects unknown provider" {
  export OPENAI_API_KEY="test-key"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider badprovider --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "Unknown provider" ]]
}

@test "provider flag requires a value" {
  run "$AICOMMIT_SCRIPT" --provider
  [ "$status" -ne 0 ]
  [[ "$output" =~ "requires a value" ]]
}

@test "provider flag rejects missing value before another flag" {
  run "$AICOMMIT_SCRIPT" --provider --yes
  [ "$status" -ne 0 ]
  [[ "$output" =~ "--provider requires a value" ]]
}

@test "model flag requires a value" {
  run "$AICOMMIT_SCRIPT" --model
  [ "$status" -ne 0 ]
  [[ "$output" =~ "--model requires a value" ]]
}

@test "model flag rejects missing value before another flag" {
  run "$AICOMMIT_SCRIPT" --model --yes
  [ "$status" -ne 0 ]
  [[ "$output" =~ "--model requires a value" ]]
}

@test "openai provider requires OPENAI_API_KEY" {
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider openai --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "OPENAI_API_KEY" ]]
}

@test "anthropic provider requires ANTHROPIC_API_KEY" {
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider anthropic --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "ANTHROPIC_API_KEY" ]]
}

@test "gemini provider requires GEMINI_API_KEY" {
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider gemini --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "GEMINI_API_KEY" ]]
}

@test "groq provider requires GROQ_API_KEY" {
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider groq --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "GROQ_API_KEY" ]]
}

@test "custom provider requires AICOMMIT_CUSTOM_API_URL and AICOMMIT_CUSTOM_API_KEY" {
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider custom --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" =~ "AICOMMIT_CUSTOM_API_URL" ]]
}

@test "auto-detects openai when OPENAI_API_KEY is set" {
  export OPENAI_API_KEY="test-key"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --yes --no-push
  # It should detect openai and attempt to call the API (will fail with invalid key)
  [[ "$output" =~ "provider: openai" ]]
}

@test "config file is read for default provider" {
  export GROQ_API_KEY="test-key"
  echo "AICOMMIT_PROVIDER=groq" > "$HOME/.aicommitrc"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --yes --no-push
  [[ "$output" =~ "provider: groq" ]]
}

@test "CLI --provider overrides config file" {
  export OPENAI_API_KEY="test-key"
  export GROQ_API_KEY="test-key"
  echo "AICOMMIT_PROVIDER=groq" > "$HOME/.aicommitrc"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider openai --yes --no-push
  [[ "$output" =~ "provider: openai" ]]
}

@test "AICOMMIT_PROVIDER env var overrides config file" {
  export OPENAI_API_KEY="test-key"
  export GROQ_API_KEY="test-key"
  export AICOMMIT_PROVIDER="openai"
  echo "AICOMMIT_PROVIDER=groq" > "$HOME/.aicommitrc"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --yes --no-push
  [[ "$output" =~ "provider: openai" ]]
}

@test "provider model default is shown in output" {
  export OPENAI_API_KEY="test-key"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider openai --yes --no-push
  [[ "$output" =~ "provider: openai, model: gpt-4o-mini" ]]
}

@test "CLI --model overrides provider default model" {
  export OPENAI_API_KEY="test-key"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider openai --model gpt-4.1-mini --yes --no-push
  [[ "$output" =~ "provider: openai, model: gpt-4.1-mini" ]]
}

@test "provider-specific model env var is used when --model is not set" {
  export OPENAI_API_KEY="test-key"
  export AICOMMIT_OPENAI_MODEL="gpt-4.1-mini"
  echo "test" > test.txt
  git add test.txt
  run "$AICOMMIT_SCRIPT" --provider openai --yes --no-push
  [[ "$output" =~ "provider: openai, model: gpt-4.1-mini" ]]
}
