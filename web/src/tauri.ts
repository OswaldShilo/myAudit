type TauriDialog = {
  open: (opts: { directory?: boolean; multiple?: boolean; title?: string }) => Promise<string | string[] | null>
}

type TauriOpener = {
  openUrl: (url: string) => Promise<void>
}

type TauriGlobal = {
  dialog?: TauriDialog
  opener?: TauriOpener
}

function tauri(): TauriGlobal | undefined {
  return (window as unknown as { __TAURI__?: TauriGlobal }).__TAURI__
}

/** True when running inside the Tauri desktop shell (not a plain browser tab). */
export function isDesktopApp(): boolean {
  const w = window as unknown as { __TAURI__?: TauriGlobal; __TAURI_INTERNALS__?: unknown }
  return !!(w.__TAURI__ || w.__TAURI_INTERNALS__)
}

/** Native folder picker; returns null in the browser or when cancelled. */
export async function pickFolder(title = 'Select a repository to audit'): Promise<string | null> {
  const dlg = tauri()?.dialog
  if (!dlg?.open) return null
  const picked = await dlg.open({ directory: true, multiple: false, title })
  return typeof picked === 'string' ? picked : null
}

export function openExternal(url: string) {
  const opener = tauri()?.opener
  if (opener?.openUrl) {
    opener.openUrl(url).catch(() => {
      window.open(url, '_blank', 'noopener,noreferrer')
    })
    return
  }
  window.open(url, '_blank', 'noopener,noreferrer')
}
