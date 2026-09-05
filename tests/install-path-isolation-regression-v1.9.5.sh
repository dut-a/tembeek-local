#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

grep -Fq 'Collision at destination' Makefile
grep -Fq 'This does not block installation' Makefile
grep -Fq -- '-ef "$$dest_file"' Makefile

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$TMP/existing-path/bin" "$TMP/prefix/bin"
cat > "$TMP/existing-path/bin/tl" <<'EOF'
#!/usr/bin/env bash
echo unrelated-host-tl
EOF
chmod +x "$TMP/existing-path/bin/tl"

PATH="$TMP/existing-path/bin:$PATH" \
  make --no-print-directory install PREFIX="$TMP/prefix" \
  >"$TMP/install.out" 2>"$TMP/install.err"

[[ -x "$TMP/prefix/bin/tembeek-local" ]]
[[ -L "$TMP/prefix/bin/tl" ]]
[[ "$(readlink "$TMP/prefix/bin/tl")" == "tembeek-local" ]]

rm -f "$TMP/prefix/bin/tl"
printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP/prefix/bin/tl"
chmod +x "$TMP/prefix/bin/tl"
if PATH="$TMP/existing-path/bin:$PATH" \
   make --no-print-directory install PREFIX="$TMP/prefix" >/dev/null 2>&1; then
  echo "expected destination collision failure" >&2
  exit 1
fi

echo INSTALL_PATH_ISOLATION_195_OK
