#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.local/bin"
TARGET="$TARGET_DIR/tembeek-local"

mkdir -p "$TARGET_DIR"
chmod +x "$SCRIPT_DIR/bin/tembeek-local"
ln -sf "$SCRIPT_DIR/bin/tembeek-local" "$TARGET"

echo "Installed tembeek-local -> $TARGET"
echo "Version: $("$TARGET" version)"

case ":$PATH:" in
  *":$TARGET_DIR:"*) ;;
  *)
    echo
    echo "Add this to ~/.zshrc:"
    echo '  export PATH="$HOME/.local/bin:$PATH"'
    ;;
esac
