#!/usr/bin/env bats

load ../helpers/setup

@test "CHANGELOG format validation" {
  PROJECT_ROOT=$(get_project_root)
  cd "$PROJECT_ROOT" || exit 1
  [ -f CHANGELOG.md ]
  run grep "# Changelog" CHANGELOG.md
  [ "$status" -eq 0 ]
  run grep "## \[Unreleased\]" CHANGELOG.md
  [ "$status" -eq 0 ]
  run grep "keepachangelog.com" CHANGELOG.md
  [ "$status" -eq 0 ]
}

@test "CHANGELOG has standard sections" {
  PROJECT_ROOT=$(get_project_root)
  cd "$PROJECT_ROOT" || exit 1
  [ -f CHANGELOG.md ]
  # Check for at least one standard section marker
  run grep -E "### (Added|Changed|Deprecated|Removed|Fixed|Security)" CHANGELOG.md
  [ "$status" -eq 0 ]
}

@test "CHANGELOG.md exists in project root" {
  PROJECT_ROOT=$(get_project_root)
  cd "$PROJECT_ROOT" || exit 1
  [ -f CHANGELOG.md ]
}
