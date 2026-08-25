#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI path required}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# Source CLI without main dispatch.
LIB="$TMP/lib.sh"
sed '/^main "\$@"$/d' "$CLI" > "$LIB"
# shellcheck disable=SC1090
source "$LIB"

P="$TMP/project"
mkdir -p \
  "$P/.tembeek" \
  "$P/resto-menus/menu-generator/.sites-runtime/npm-cache/_logs" \
  "$P/resto-menus/menu-generator/.wrangler/registry" \
  "$P/resto-menus/menu-generator/publish-bridge"

cat > "$P/.env" <<'EOF'
APP_ENV=local
APP_URL=https://tembeek.localhost
EOF
cat > "$P/.tembeek/local.yaml" <<'EOF'
alias: tembeek
EOF
echo '5 silly config load:file:~/.npmrc' > "$P/resto-menus/menu-generator/.sites-runtime/npm-cache/_logs/a.log"
echo '"debugPortAddress":"127.0.0.1:61413"' > "$P/resto-menus/menu-generator/.wrangler/registry/x"
echo '- docs mention localhost:8080' > "$P/TODO.md"
cat > "$P/resto-menus/menu-generator/publish-bridge/receive.php.example" <<'EOF'
/home/CPANEL_USER/private-config/menu-publish-secret.php
EOF
cat > "$P/.htaccess" <<'EOF'
RewriteEngine On
# LOCAL: preserve *.localhost and only upgrade HTTP -> HTTPS.
RewriteCond %{HTTP_HOST} \.localhost(?::[0-9]+)?$ [NC]
RewriteCond %{HTTPS} !=on
RewriteRule ^ https://%{HTTP_HOST}%{REQUEST_URI} [R=302,L,NE]
EOF

scan_find_files "$P" | grep -q '.sites-runtime' && exit 10 || true
scan_find_files "$P" | grep -q '.wrangler' && exit 11 || true
check_absolute_paths "$P" >/dev/null
check_localhost_leakage "$P" | grep -q 'No unexpected localhost'
check_htaccess_portability "$P" | grep -q 'portability-safe'

echo SCANNER_REGRESSION_OK
