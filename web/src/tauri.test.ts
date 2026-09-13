import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest'
import { isDesktopApp, pickFolder } from './tauri'

type Win = { __TAURI__?: { dialog?: { open: ReturnType<typeof vi.fn> } }; __TAURI_INTERNALS__?: unknown }

describe('tauri helpers', () => {
  beforeEach(() => {
    vi.stubGlobal('window', {} as Win)
  })

  afterEach(() => {
    vi.unstubAllGlobals()
  })

  it('isDesktopApp is false in a plain browser', () => {
    expect(isDesktopApp()).toBe(false)
  })

  it('isDesktopApp is true when __TAURI__ is present', () => {
    (window as Win).__TAURI__ = { dialog: { open: vi.fn() } }
    expect(isDesktopApp()).toBe(true)
  })

  it('pickFolder returns null without Tauri dialog', async () => {
    expect(await pickFolder()).toBeNull()
  })

  it('pickFolder returns a string path from the native dialog', async () => {
    const open = vi.fn().mockResolvedValue('/Users/me/project');
    (window as Win).__TAURI__ = { dialog: { open } }
    await expect(pickFolder('Pick repo')).resolves.toBe('/Users/me/project')
    expect(open).toHaveBeenCalledWith({ directory: true, multiple: false, title: 'Pick repo' })
  })
})
