#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"

extract_fn() {
  local name="$1"
  awk -v n="$name" '
    $0 ~ "^" n "\\(\\) \\{" {infn=1}
    infn {print}
    infn && /^}$/ {exit}
  ' "$CLI"
}

for fn in cmd_up cmd_down cmd_status; do
  body="$(extract_fn "$fn")"
  ! grep -Eq '(^|[[:space:]])info[[:space:]]+"' <<<"$body"
done

echo LIFECYCLE_INFO_COLLISION_REGRESSION_OK
