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
<FilesMatch "^(README|DEPLOYMENT)\.md$|^(composer(?:\.lock|\.json)|phpunit\.xml(?:\.dist)?)$">
  <IfModule mod_authz_core.c>
    Require all denied
  </IfModule>
</FilesMatch>

<IfModule mod_rewrite.c>
  RewriteEngine On
  RewriteRule ^(?:\.git|\.tembeek)(?:/|$) - [F,L,NC]
  RewriteRule ^\.env(?:\..*)?$ - [F,L,NC]
  RewriteRule ^composer(?:[.]json|[.]lock)$ - [F,L,NC]
  RewriteRule ^phpunit[.]xml$ - [F,L,NC]
  RewriteRule ^phpunit[.]xml(?:\.dist)?$ - [F,L,NC]
</IfModule>
EOF

OUT="$(check_sensitive_files "$P" "$P")"

for f in .env .git/config composer.json composer.lock phpunit.xml phpunit.xml.dist; do
  grep -Fq "Web-root internal file is explicitly blocked: $f" <<<"$OUT"
done

! grep -Fq 'web-root visible' <<<"$OUT"
! grep -Fq 'not explicitly blocked' <<<"$OUT"

echo SENSITIVE_WEBROOT_SEMANTIC_REGRESSION_OK
