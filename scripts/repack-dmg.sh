#!/usr/bin/env bash
# Build a styled drag-to-Applications DMG from a signed .app bundle.
set -euo pipefail

VERSION="${1:?usage: repack-dmg.sh <version> <MyApp.app> [out-dir]}"
APP="${2:?}"
OUT_DIR="${3:-dist}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "repack-dmg.sh is macOS-only" >&2
  exit 1
fi

if ! command -v create-dmg >/dev/null; then
  echo "create-dmg not found — install with: brew install create-dmg" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BG="$ROOT/desktop/dmg-background.png"
if [ ! -f "$BG" ]; then
  echo "missing DMG background: $BG" >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

cp -R "$APP" "$STAGING/$(basename "$APP")"

DMG="$OUT_DIR/myAudit-${VERSION}-macOS.dmg"
rm -f "$DMG"

create-dmg \
  --volname "myAudit" \
  --background "$BG" \
  --window-pos 200 120 \
  --window-size 660 400 \
  --icon-size 128 \
  --icon "myAudit.app" 180 220 \
  --hide-extension "myAudit.app" \
  --app-drop-link 480 220 \
  --no-internet-enable \
  "$DMG" \
  "$STAGING" >/dev/null

echo "  $(basename "$DMG")"
ls -la "$OUT_DIR"
