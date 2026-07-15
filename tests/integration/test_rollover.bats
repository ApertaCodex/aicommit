#!/usr/bin/env bats

load ../helpers/setup

# Get the path to the aicommit script
AICOMMIT_SCRIPT="${BATS_TEST_DIRNAME}/../../aicommit"

# Source only the version functions from the aicommit script so we can
# unit-test bump_version / apply_rollover without running the whole CLI.
setup() {
  eval "$(sed -n '/^parse_version()/,/^}/p' "$AICOMMIT_SCRIPT")"
  eval "$(sed -n '/^apply_rollover()/,/^}/p' "$AICOMMIT_SCRIPT")"
  eval "$(sed -n '/^bump_version()/,/^}/p' "$AICOMMIT_SCRIPT")"
  ROLLOVER_MAX_MINOR=10
  ROLLOVER_MAX_PATCH=100
}

@test "aicommit --rollover flag exists in help" {
  run "$AICOMMIT_SCRIPT" --help
  [ "$status" -eq 0 ]
  [[ "$output" =~ "--rollover" ]]
}

# ---------- rollover OFF (default): legacy behaviour ----------

@test "rollover off: patch does not roll over at max" {
  ROLLOVER=false
  [ "$(bump_version 1.2.99 patch)" = "1.2.100" ]
  [ "$(bump_version 1.2.100 patch)" = "1.2.101" ]
}

@test "rollover off: minor does not roll over at max" {
  ROLLOVER=false
  [ "$(bump_version 1.9.0 minor)" = "1.10.0" ]
}

# ---------- rollover ON: X.Y.Z ----------

@test "rollover on: normal patch bump unaffected" {
  ROLLOVER=true
  [ "$(bump_version 1.2.3 patch)" = "1.2.4" ]
}

@test "rollover on: patch reaching 100 carries into minor" {
  ROLLOVER=true
  [ "$(bump_version 1.2.99 patch)" = "1.3.0" ]
}

@test "rollover on: cascade patch -> minor -> major" {
  ROLLOVER=true
  [ "$(bump_version 1.9.99 patch)" = "2.0.0" ]
}

@test "rollover on: minor reaching 10 carries into major" {
  ROLLOVER=true
  [ "$(bump_version 1.9.5 minor)" = "2.0.0" ]
}

@test "rollover on: major bump unaffected" {
  ROLLOVER=true
  [ "$(bump_version 1.2.3 major)" = "2.0.0" ]
}

# ---------- rollover ON: X.Y ----------

@test "rollover on: X.Y minor reaching 10 carries into major" {
  ROLLOVER=true
  [ "$(bump_version 1.9 patch)" = "2.0" ]
  [ "$(bump_version 1.9 minor)" = "2.0" ]
}

@test "rollover on: X.Y major component has no max" {
  ROLLOVER=true
  [ "$(bump_version 9.9 patch)" = "10.0" ]
}

# ---------- rollover ON: X ----------

@test "rollover on: single-component version has no max" {
  ROLLOVER=true
  [ "$(bump_version 9 patch)" = "10" ]
  [ "$(bump_version 99 major)" = "100" ]
}

# ---------- custom maxes ----------

@test "rollover on: custom maxes are honored" {
  ROLLOVER=true
  ROLLOVER_MAX_MINOR=5
  ROLLOVER_MAX_PATCH=20
  [ "$(bump_version 1.2.19 patch)" = "1.3.0" ]
  [ "$(bump_version 1.4.19 patch)" = "2.0.0" ]
  [ "$(bump_version 1.4.0 minor)" = "2.0.0" ]
}
