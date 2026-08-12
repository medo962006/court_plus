import { useEffect, useState } from 'react'

/** Tiny data-fetching hook: returns {data, loading, error, reload}. */
export function useAsync<T>(fn: () => Promise<T>, deps: unknown[] = []) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let alive = true
    setLoading(true)
    setError(null)
    fn()
      .then((d) => alive && setData(d))
      .catch((e: Error) => alive && setError(e.message))
      .finally(() => alive && setLoading(false))
    return () => {
      alive = false
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)

  return { data, loading, error, reload: () => setLoading((s) => !s) }
}

/** Polls [fn] every [intervalMs] so live sections tick without a manual refresh. */
export function usePolling<T>(fn: () => Promise<T>, deps: unknown[] = [], intervalMs = 5000) {
  const [data, setData] = useState<T | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    let alive = true
    const run = () => {
      fn()
        .then((d) => alive && setData(d))
        .catch((e: Error) => alive && setError(e.message))
        .finally(() => alive && setLoading(false))
    }
    run()
    const id = setInterval(run, intervalMs)
    return () => {
      alive = false
      clearInterval(id)
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps)

  return { data, loading, error }
}