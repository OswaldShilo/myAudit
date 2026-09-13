#!/usr/bin/env bash
# Ad-hoc sign a macOS .app for distribution (nested binaries first).
set -euo pipefail

APP="${1:?usage: codesign-macos-app.sh <MyApp.app>}"

if [ "$(uname -s)" != "Darwin" ]; then
  echo "codesign-macos-app.sh is macOS-only" >&2
  exit 1
fi

sign() {
  codesign --force --sign - "$1"
}

while IFS= read -r -d '' bin; do
  sign "$bin"
done < <(find "$APP/Contents/MacOS" -type f -perm +111 -print0 2>/dev/null)

sign "$APP"
codesign --verify --verbose=2 "$APP"
