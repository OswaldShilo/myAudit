# Downloads

[← Documentation home](README.md)

**macOS (Apple Silicon) only** — one `.dmg` per release. No Windows/Linux/Intel builds.

**Latest release:** [github.com/codebyNJ/myAudit/releases/latest](https://github.com/codebyNJ/myAudit/releases/latest)

## Install

**One line (recommended):**

```bash
curl -fsSL https://raw.githubusercontent.com/codebyNJ/myAudit/main/scripts/install.sh | bash
```

This downloads `myAudit-*-macOS.dmg`, copies the app to `/Applications`, re-signs it, and clears quarantine so you do not get **“app is damaged”**.

**Manual:** download the `.dmg`, drag **myAudit** to Applications, then run:

```bash
codesign --force --sign - /Applications/myAudit.app/Contents/MacOS/myaudit-serve
codesign --force --sign - /Applications/myAudit.app/Contents/MacOS/desktop
codesign --force --sign - /Applications/myAudit.app
xattr -cr /Applications/myAudit.app
```

If macOS still blocks launch: **System Settings → Privacy & Security → Open Anyway**.

Pin a version: `MYAUDIT_VERSION=v0.2.2 curl -fsSL ... | bash`

After installing, launch **myAudit**. You still need **`claude`** or **`opencode`** logged in on your machine for live audits.

## Verify downloads

Each release includes `SHA256SUMS.txt`:

```bash
sha256sum -c SHA256SUMS.txt
```

## Build from source

See [Getting started](getting-started.md) if you want to develop or build locally (any platform).

## See also

- [Desktop app](desktop.md)
- [Agent providers](agent-providers.md)
