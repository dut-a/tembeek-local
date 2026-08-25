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
touch "$P/.env" "$P/.git/config" "$P/composer.json" "$P/composer.lock" "$P/phpunit.xml" "$P/phpunit.xml.dist"

cat > "$P/.htaccess" <<'EOF'
# tembeek-local: internal-webroot-protection begin
<FilesMatch "^(?:\.env(?:\..*)?|composer\.(?:json|lock)|phpunit\.xml(?:\.dist)?)$">
  Require all denied
</FilesMatch>
<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteRule ^(?:\.git|\.tembeek)(?:/|$) - [F,L,NC]
  RewriteRule ^\.env(?:\..*)?$ - [F,L,NC]
  RewriteRule ^composer\.(?:json|lock)$ - [F,L,NC]
  RewriteRule ^phpunit\.xml(?:\.dist)?$ - [F,L,NC]
</IfModule>
# tembeek-local: internal-webroot-protection end
EOF

htaccess_has_internal_webroot_protection "$P/.htaccess"
check_sensitive_files "$P" "$P" >/dev/null
echo SENSITIVE_WEBROOT_REGRESSION_OK
