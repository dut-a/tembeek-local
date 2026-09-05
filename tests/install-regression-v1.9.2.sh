#!/usr/bin/env bash
set -euo pipefail
CLI="${1:?CLI required}"
README="${2:?README required}"

grep -Fq 'SHORT_NAME := tl' Makefile
grep -Fq 'install:' Makefile
grep -Fq 'uninstall:' Makefile
grep -Fq 'make install' "$README"

HELP="$("$CLI" --help)"
grep -Fq 'make install' <<<"$HELP"
grep -Fq 'tl                    Short executable alias' <<<"$HELP"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

make --no-print-directory install PREFIX="$TMP/prefix" >/dev/null
[[ -x "$TMP/prefix/bin/tembeek-local" ]]
[[ -L "$TMP/prefix/bin/tl" ]]
[[ "$(readlink "$TMP/prefix/bin/tl")" == "tembeek-local" ]]

"$TMP/prefix/bin/tembeek-local" --version >/dev/null
"$TMP/prefix/bin/tl" --version >/dev/null

mkdir -p "$TMP/collision/bin"
printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP/collision/bin/tl"
chmod +x "$TMP/collision/bin/tl"
if PATH="$TMP/collision/bin:$PATH" make --no-print-directory install PREFIX="$TMP/other" >/dev/null 2>&1; then
  echo "expected tl collision failure" >&2
  exit 1
fi

make --no-print-directory uninstall PREFIX="$TMP/prefix" >/dev/null
[[ ! -e "$TMP/prefix/bin/tl" ]]
[[ ! -e "$TMP/prefix/bin/tembeek-local" ]]

echo INSTALL_REGRESSION_192_OK
