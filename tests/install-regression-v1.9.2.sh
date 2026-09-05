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
grep -Fq 'Installed commands' <<<"$HELP"
grep -Fq 'Canonical command' <<<"$HELP"
grep -Fq 'Short executable alias for tembeek-local' <<<"$HELP"

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

make --no-print-directory install PREFIX="$TMP/prefix" >/dev/null
[[ -x "$TMP/prefix/bin/tembeek-local" ]]
[[ -L "$TMP/prefix/bin/tl" ]]
[[ "$(readlink "$TMP/prefix/bin/tl")" == "tembeek-local" ]]

"$TMP/prefix/bin/tembeek-local" --version >/dev/null
"$TMP/prefix/bin/tl" --version >/dev/null

mkdir -p "$TMP/other/bin"
printf '#!/usr/bin/env bash\nexit 0\n' > "$TMP/other/bin/tl"
chmod +x "$TMP/other/bin/tl"
if make --no-print-directory install PREFIX="$TMP/other" >/dev/null 2>&1; then
  echo "expected destination tl collision failure" >&2
  exit 1
fi

make --no-print-directory uninstall PREFIX="$TMP/prefix" >/dev/null
[[ ! -e "$TMP/prefix/bin/tl" ]]
[[ ! -e "$TMP/prefix/bin/tembeek-local" ]]

echo INSTALL_REGRESSION_192_OK
