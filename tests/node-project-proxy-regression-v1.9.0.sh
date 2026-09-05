#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

grep -Fq 'echo "node"' "$CLI"
grep -Fq 'framework: $framework' "$CLI"
grep -Fq 'runtime_mode: process-proxy' "$CLI"
grep -Fq 'ProxyPass "/" "http://127.0.0.1:${port}/" upgrade=websocket' "$CLI"
grep -Fq 'proxy_module' "$CLI"
grep -Fq 'proxy_http_module' "$CLI"
grep -Fq 'cmd_project_up()' "$CLI"
grep -Fq 'cmd_project_down()' "$CLI"
grep -Fq 'cmd_project_status()' "$CLI"
grep -Fq -- '--strictPort' "$CLI"

HELP="$("$CLI" --help)"
grep -Fq 'project up <key>' <<<"$HELP"
grep -Fq 'project down <key>' <<<"$HELP"
grep -Fq 'project status <key>' <<<"$HELP"
grep -Fq 'Process-backed Node / Astro / React projects' "$README"

# deterministic alias port function contract
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
LIB="$TMP/lib.sh"
sed '/^main "\$@"$/d' "$CLI" > "$LIB"
source "$LIB"
p1="$(node_port_for_alias example)"
p2="$(node_port_for_alias example)"
[[ "$p1" == "$p2" ]]
[[ "$p1" -ge "$NODE_PORT_MIN" && "$p1" -le "$NODE_PORT_MAX" ]]

echo NODE_PROJECT_PROXY_190_OK
