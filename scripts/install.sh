#!/usr/bin/env bash
# Install myAudit for macOS (Apple Silicon) from the latest GitHub Release.
# Usage: curl -fsSL https://raw.githubusercontent.com/codebyNJ/myAudit/main/scripts/install.sh | bash
set -euo pipefail

REPO="${MYAUDIT_INSTALL_REPO:-codebyNJ/myAudit}"
VERSION="${MYAUDIT_VERSION:-latest}"
API="https://api.github.com/repos/${REPO}/releases/${VERSION}"

OS="$(uname -s)"
ARCH="$(uname -m)"

if [ "$OS" != "Darwin" ]; then
  echo "install.sh is for macOS only — see https://github.com/${REPO}/releases" >&2
  exit 1
fi

if [ "$ARCH" != "arm64" ]; then
  echo "releases are Apple Silicon (arm64) only; this Mac is ${ARCH}" >&2
  exit 1
fi

# New name first, then legacy v0.2.x asset names.
PATTERN='myAudit-.*-macOS(\.dmg|-AppleSilicon\.dmg)$'

echo "==> fetching release metadata from ${REPO}"
JSON="$(curl -fsSL -H "Accept: application/vnd.github+json" "$API")"

URL="$(echo "$JSON" | python3 -c 'import json,re,sys; d=json.load(sys.stdin); p=re.compile(sys.argv[1]); print(next((a["browser_download_url"] for a in d.get("assets",[]) if p.search(a.get("name",""))), ""))' "$PATTERN")"

if [ -z "$URL" ]; then
  echo "no macOS installer found" >&2
  echo "see https://github.com/${REPO}/releases" >&2
  exit 1
fi

FILE="$(basename "$URL")"
TMP="${TMPDIR:-/tmp}/myaudit-install"
mkdir -p "$TMP"
DEST="$TMP/$FILE"

echo "==> downloading $FILE"
curl -fsSL -o "$DEST" "$URL"

echo "==> mounting disk image"
MOUNT="$(hdiutil attach "$DEST" -nobrowse | grep -o '/Volumes/.*' | tail -1)"
if [ -z "$MOUNT" ] || [ ! -d "$MOUNT/myAudit.app" ]; then
  echo "myAudit.app not found in DMG" >&2
  hdiutil detach "$MOUNT" -quiet 2>/dev/null || true
  exit 1
fi

APP_DEST="/Applications/myAudit.app"
echo "==> installing to $APP_DEST"
rm -rf "$APP_DEST"
cp -R "$MOUNT/myAudit.app" "$APP_DEST"
hdiutil detach "$MOUNT" -quiet

# Unsigned builds: re-sign nested binaries, then clear quarantine.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -x "$SCRIPT_DIR/codesign-macos-app.sh" ]; then
  "$SCRIPT_DIR/codesign-macos-app.sh" "$APP_DEST"
else
  codesign --force --sign - "$APP_DEST/Contents/MacOS/myaudit-serve"
  codesign --force --sign - "$APP_DEST/Contents/MacOS/desktop"
  codesign --force --sign - "$APP_DEST"
fi
xattr -cr "$APP_DEST"

echo "==> installed. Open myAudit from Applications (or Spotlight)."
echo "    First launch: if macOS asks to confirm, choose Open."
echo "    Or: System Settings → Privacy & Security → Open Anyway"
