#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI path required}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

LIB="$TMP/lib.sh"
sed '/^main "\$@"$/d' "$CLI" > "$LIB"
source "$LIB"

P="$TMP/project"
mkdir -p "$P/.git"
touch "$P/.env" "$P/.git/config"

cat > "$P/.htaccess" <<'EOF'
<FilesMatch "^(?:\.env(?:\..*)?|composer\.(?:json|lock)|phpunit\.xml(?:\.dist)?)$">
  <IfModule mod_authz_core.c>
    Require all denied
  </IfModule>
  <IfModule !mod_authz_core.c>
    Order allow,deny
    Deny from all
  </IfModule>
</FilesMatch>

<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteRule ^(?:\.git|\.tembeek)(?:/|$) - [F,L,NC]
  RewriteRule ^\.env(?:\..*)?$ - [F,L,NC]
</IfModule>
EOF

htaccess_blocks_sensitive_file "$P/.htaccess" ".env"
htaccess_blocks_sensitive_file "$P/.htaccess" ".git/config"

OUT="$(check_sensitive_files "$P" "$P")"
grep -Fq 'Web-root internal file is explicitly blocked: .env' <<<"$OUT"
grep -Fq 'Web-root internal file is explicitly blocked: .git/config' <<<"$OUT"

echo ENV_GIT_PROTECTION_REGRESSION_OK
