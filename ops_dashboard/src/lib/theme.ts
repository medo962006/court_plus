import { useEffect, useState } from 'react'

const KEY = 'ops-dark'

export function isDark(): boolean {
  return localStorage.getItem(KEY) === '1'
}

export function applyDark(dark: boolean): void {
  document.documentElement.classList.toggle('dark', dark)
  localStorage.setItem(KEY, dark ? '1' : '0')
  window.dispatchEvent(new Event('ops:theme'))
}

/** Shared dark-mode state, kept in sync across components (Topbar, charts, pills…). */
export function useDark(): [boolean, (d: boolean | ((prev: boolean) => boolean)) => void] {
  const [dark, setDark] = useState<boolean>(isDark)
  useEffect(() => {
    applyDark(dark)
    const onChange = () => setDark(isDark())
    window.addEventListener('ops:theme', onChange)
    return () => window.removeEventListener('ops:theme', onChange)
  }, [dark])
  return [dark, setDark]
}
