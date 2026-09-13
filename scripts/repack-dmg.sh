#!/usr/bin/env bash
# Build a drag-to-Applications DMG from a signed .app bundle.
set -euo pipefail

VERSION="${1:?usage: repack-dmg.sh <version> <MyApp.app> [out-dir]}"
APP="${2:?}"
OUT_DIR="${3:-dist}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "repack-dmg.sh is macOS-only" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

cp -R "$APP" "$STAGING/$(basename "$APP")"
ln -s /Applications "$STAGING/Applications"

DMG="$OUT_DIR/myAudit-${VERSION}-macOS.dmg"
rm -f "$DMG"
hdiutil create -volname "myAudit" -srcfolder "$STAGING" -ov -format UDZO "$DMG" >/dev/null

echo "  $(basename "$DMG")"
ls -la "$OUT_DIR"
