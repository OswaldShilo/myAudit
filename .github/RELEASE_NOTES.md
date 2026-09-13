**macOS (Apple Silicon):** download `myAudit-*-macOS.dmg` or run:

```bash
curl -fsSL https://raw.githubusercontent.com/codebyNJ/myAudit/main/scripts/install.sh | bash
```

If you installed manually and see **“app is damaged”**, run:

```bash
codesign --force --sign - /Applications/myAudit.app/Contents/MacOS/myaudit-serve
codesign --force --sign - /Applications/myAudit.app/Contents/MacOS/desktop
codesign --force --sign - /Applications/myAudit.app
xattr -cr /Applications/myAudit.app
```

Verify with `SHA256SUMS.txt`. Details: [docs/downloads.md](https://github.com/codebyNJ/myAudit/blob/main/docs/downloads.md)
