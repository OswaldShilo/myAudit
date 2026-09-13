#!/usr/bin/env bash
# Rename Tauri bundle outputs to predictable download names for GitHub Releases.
set -euo pipefail

VERSION="${1:?usage: package-release.sh <version> <bundle-dir> <triple> <out-dir>}"
BUNDLE_DIR="${2:?}"
TRIPLE="${3:?}"
OUT="${4:-dist}"

mkdir -p "$OUT"
V="$VERSION"

copy_one() {
  local src="$1" dest="$2"
  if [ -f "$src" ]; then
    cp "$src" "$OUT/$dest"
    echo "  $dest"
  fi
}

case "$TRIPLE" in
  aarch64-apple-darwin)
    copy_one "$(find "$BUNDLE_DIR/dmg" -maxdepth 1 -name '*.dmg' 2>/dev/null | head -1)" "myAudit-${V}-macOS.dmg"
    ;;
  *)
    echo "unknown triple: $TRIPLE (releases are macOS Apple Silicon only)" >&2
    exit 1
    ;;
esac

if [ -z "$(ls -A "$OUT" 2>/dev/null)" ]; then
  echo "no release artifacts found under $BUNDLE_DIR" >&2
  exit 1
fi

ls -la "$OUT"
