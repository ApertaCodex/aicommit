#!/usr/bin/env bats
# Provider-error handling against a local OpenAI-compatible stub server.

load ../helpers/setup

AICOMMIT_SCRIPT="${BATS_TEST_DIRNAME}/../../aicommit"
STUB="${BATS_TEST_DIRNAME}/../helpers/stub_server.py"

ERR_400='{"status":400,"body":{"error":{"message":"thinking.enabled.budget_tokens: Input should be greater than or equal to 1024","type":"invalid_request_error"}}}'
ok_reply() { printf '{"status":200,"body":{"choices":[{"message":{"content":"%s"}}]}}' "$1"; }

setup() {
  command -v python3 >/dev/null || skip "python3 required for stub server"
  setup_test_repo >/dev/null
  setup_git_config
  git checkout -q -b main
  unset OPENAI_API_KEY AICOMMIT_PROVIDER AICOMMIT_MODEL_URL AICOMMIT_OPENAI_MODEL
  rm -f "$HOME/.aicommitrc"
  export AICOMMIT_RETRY_DELAY=0 AICOMMIT_JUST_UPGRADED=1   # no network update check
  STUB_DIR=$(mktemp -d)
}

teardown() {
  [[ -n "${STUB_PID:-}" ]] && kill "$STUB_PID" 2>/dev/null || true
  rm -rf "${STUB_DIR:-}"
  teardown_test_repo
}

# start_stub '<json entry>' ['<json entry>' ...]
start_stub() {
  local IFS=,
  printf '[%s]' "$*" > "$STUB_DIR/responses.json"
  python3 "$STUB" "$STUB_DIR/responses.json" "$STUB_DIR/port" "$STUB_DIR/requests.log" &
  STUB_PID=$!
  for _ in $(seq 50); do [[ -s "$STUB_DIR/port" ]] && break; sleep 0.1; done
  STUB_PORT=$(cat "$STUB_DIR/port")
  STUB_URL="http://127.0.0.1:${STUB_PORT}/v1"
}

request_count() { [[ -f "$STUB_DIR/requests.log" ]] && wc -l < "$STUB_DIR/requests.log" | tr -d ' ' || echo 0; }

seed_release_repo() {
  echo "1.0.0" > VERSION
  git add VERSION && git commit -qm "chore: init"
  git tag -a v1.0.0 -m v1.0.0
}

@test "commit: HTTP 400 is reported once, not retried, and named by host" {
  start_stub "$ERR_400"
  echo a > a.txt; mkdir -p sub; echo b > sub/b.txt
  run "$AICOMMIT_SCRIPT" --provider openai --model-url "$STUB_URL" --effect low --yes --no-push
  [ "$status" -eq 0 ]
  [ "$(request_count)" -eq 1 ]
  [[ "$output" != *"empty AI response"* ]]
  [[ "$output" != *"OpenAI API"* ]]
  [[ "$output" == *"127.0.0.1:${STUB_PORT} (openai-compatible): HTTP 400"* ]]
  [ "$(grep -c "^aicommit: Error from" <<<"$output")" -eq 1 ]   # real error printed once
  [[ "$output" == *"WARNING: AI commit message generation failed"*"budget_tokens"* ]]
  # deterministic, descriptive fallback committed
  [[ "$(git log -1 --format=%s)" == "chore: update (root), sub (2 files)" ]]
  [[ "$(git log -1 --format=%b)" == *"- sub/b.txt"* ]]
}

@test "commit: request shape carries max_tokens 2048 and effect low" {
  start_stub "$(ok_reply 'feat: add a')"
  echo a > a.txt
  run "$AICOMMIT_SCRIPT" --provider openai --model-url "$STUB_URL" --effect low --yes --no-push
  [ "$status" -eq 0 ]
  jq -e '.max_tokens == 2048 and .effect == "low"' "$STUB_DIR/requests.log"
  [[ "$(git log -1 --format=%s)" == "feat: add a" ]]
}

@test "commit: 503 and 429 are retried with backoff, then succeed" {
  start_stub '{"status":503,"body":{"error":{"message":"overloaded"}}}' \
             '{"status":429,"body":{"error":{"message":"rate limited"}}}' \
             "$(ok_reply 'fix: handle b')"
  echo b > b.txt
  run "$AICOMMIT_SCRIPT" --provider openai --model-url "$STUB_URL" --yes --no-push
  [ "$status" -eq 0 ]
  [ "$(request_count)" -eq 3 ]
  [[ "$output" == *"HTTP 503: overloaded (attempt 1/3); retrying"* ]]
  [[ "$output" == *"HTTP 429: rate limited (attempt 2/3); retrying"* ]]
  [[ "$(git log -1 --format=%s)" == "fix: handle b" ]]
}

@test "commit: JSON error field on HTTP 200 is a provider error, not empty content" {
  start_stub '{"status":200,"body":{"error":{"message":"model not found"}}}'
  echo c > c.txt
  run "$AICOMMIT_SCRIPT" --provider openai --model-url "$STUB_URL" --yes --no-push
  [ "$status" -eq 0 ]
  [ "$(request_count)" -eq 1 ]
  [[ "$output" == *"model not found"* ]]
  [[ "$output" != *"empty AI response"* ]]
}

@test "release: bump-type provider error falls back to deterministic minor" {
  seed_release_repo
  git commit -q --allow-empty -m "feat: new thing"
  git commit -q --allow-empty -m "fix: small"
  start_stub "$ERR_400"
  run "$AICOMMIT_SCRIPT" --release --provider openai --model-url "$STUB_URL" --yes --no-push
  [ "$status" -eq 0 ]
  [[ "$output" != *"unexpected bump type"* ]]
  [[ "$output" == *"AI bump detection failed"*"budget_tokens"*"deterministic bump 'minor'"* ]]
  git rev-parse -q --verify refs/tags/v1.1.0
  [ "$(cat VERSION)" = "1.1.0" ]
}

@test "release: deterministic fallback detects breaking changes (major)" {
  seed_release_repo
  git commit -q --allow-empty -m "feat(api)!: drop v1 endpoints"
  start_stub "$ERR_400"
  run "$AICOMMIT_SCRIPT" --release --provider openai --model-url "$STUB_URL" --yes --no-push
  [ "$status" -eq 0 ]
  git rev-parse -q --verify refs/tags/v2.0.0
}

@test "release: invalid AI bump answer falls back instead of aborting" {
  seed_release_repo
  git commit -q --allow-empty -m "docs: readme"
  start_stub "$(ok_reply 'I think it is a minor-ish change')"
  run "$AICOMMIT_SCRIPT" --release --provider openai --model-url "$STUB_URL" --yes --no-push
  [ "$status" -eq 0 ]
  [[ "$output" == *"unexpected bump type"*"deterministic bump 'patch'"* ]]
  git rev-parse -q --verify refs/tags/v1.0.1
}

@test "release: failure after bumping rolls the version files back" {
  seed_release_repo
  # A pre-existing, unreachable v1.0.1 tag makes the tagging step fail.
  git checkout -q -b side && git commit -q --allow-empty -m "side" && git tag -a v1.0.1 -m side
  git checkout -q main
  git commit -q --allow-empty -m "fix: thing"
  local head; head=$(git rev-parse HEAD)
  start_stub "$(ok_reply 'patch')"
  run "$AICOMMIT_SCRIPT" --release --provider openai --model-url "$STUB_URL" --yes --no-push
  [ "$status" -ne 0 ]
  [[ "$output" == *"rolling back"* ]]
  [ "$(cat VERSION)" = "1.0.0" ]
  [ "$(git rev-parse HEAD)" = "$head" ]
  [ -z "$(git status --porcelain)" ]
}
