#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
sed '/^main "\$@"$/d' "$CLI" > "$TMP/lib.sh"
source "$TMP/lib.sh"
P="$TMP/project"
mkdir -p "$P/.tembeek"
projects_json_has() { [[ "$1" == "site" ]]; }
projects_json_get() { printf '%s\n' "$P"; }
cmd_project_restart() {
  [[ "$(yaml_value "$P/.tembeek/local.yaml" package_manager)" == pnpm ]]
  echo "$1" > "$TMP/restarted"
}
cat > "$P/package.json" <<'JSON'
{"scripts":{"dev":"vite"},"devDependencies":{"vite":"*"}}
JSON
cat > "$P/.tembeek/local.yaml" <<'YAML'
type: node
framework: astro
package_manager: npm
dev_script: start
alias: custom
dev_port: 43123
autostart: true
policy_exceptions: []
# preserve comments
YAML
manifest="$P/.tembeek/local.yaml"
sed '/^framework:/d; /^package_manager:/d; /^dev_script:/d' "$manifest" > "$TMP/preserved"
touch "$P/pnpm-lock.yaml"
cmd_project rescan site > "$TMP/output"
[[ "$(yaml_value "$manifest" package_manager)" == pnpm ]]
[[ "$(yaml_value "$manifest" framework)" == vite ]]
[[ "$(yaml_value "$manifest" dev_script)" == dev ]]
[[ ! -e "$TMP/restarted" ]]
sed '/^framework:/d; /^package_manager:/d; /^dev_script:/d' "$manifest" > "$TMP/actual"
cmp "$TMP/preserved" "$TMP/actual"
cp "$manifest" "$TMP/expected"
cmd_project rescan site --restart > /dev/null
cmp "$manifest" "$TMP/expected"
[[ "$(cat "$TMP/restarted")" == site ]]
for args in 'missing' 'site --bad' 'site --restart extra'; do
  if (cmd_project rescan $args) > /dev/null 2>&1; then exit 1; fi
done
cmp "$manifest" "$TMP/expected"
echo '{}' > "$P/package.json"
if (cmd_project rescan site) > /dev/null 2>&1; then exit 1; fi
cmp "$manifest" "$TMP/expected"
rm "$manifest"
if (cmd_project rescan site) > /dev/null 2>&1; then exit 1; fi
[[ ! -e "$manifest" ]]
echo PROJECT_RESCAN_OK
