#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
command -v php >/dev/null 2>&1 || { echo "SKIP: php unavailable"; exit 0; }

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

LIB="$TMP/lib.sh"
sed '/^main "\$@"$/d' "$CLI" > "$LIB"
source "$LIB"

active_php_bin() { command -v php; }
DEV_ROOT="$TMP/dev"
PROJECTS_FILE="$TMP/config/projects.json"
TEMBEEK_PROJECT_ROOTS="$DEV_ROOT"

mkdir -p "$DEV_ROOT/alpha/.tembeek" "$DEV_ROOT/beta/.tembeek"

cat > "$DEV_ROOT/alpha/.tembeek/local.yaml" <<'EOF'
schema_version: 1
project: alpha
registry_key: alpha
alias: alpha
database_engine: mysql
migration_command: php bin/migrate.php
bootstrap_database: true
bootstrap_migrate: true
bootstrap_doctor: true
EOF

cat > "$DEV_ROOT/beta/.tembeek/local.yaml" <<'EOF'
schema_version: 1
project: beta
alias: beta
database_engine: none
EOF

json1="$(project_recovery_json)"
json2="$(project_recovery_json)"
[[ "$json1" == "$json2" ]]

project_registry_write_atomic "$json1"
[[ -f "$PROJECTS_FILE" ]]
grep -q '"alpha"' "$PROJECTS_FILE"
grep -q '"beta"' "$PROJECTS_FILE"

rm "$PROJECTS_FILE"
ensure_projects_file
[[ -f "$PROJECTS_FILE" ]]
grep -q '"alpha"' "$PROJECTS_FILE"

cmd_project_registry_verify >/dev/null

echo PROJECT_REGISTRY_RECOVERY_180_OK
