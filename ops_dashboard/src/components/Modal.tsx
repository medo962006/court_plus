import { X } from '@phosphor-icons/react'
import type { ReactNode } from 'react'

export default function Modal({
  open,
  title,
  onClose,
  children,
}: {
  open: boolean
  title: string
  onClose: () => void
  children: ReactNode
}) {
  if (!open) return null
  return (
    <div className="fixed inset-0 z-50 grid place-items-center bg-slate-900/40 p-4">
      <div className="w-full max-w-lg overflow-hidden rounded-xl border border-line bg-panel shadow-xl">
        <div className="flex items-center justify-between border-b border-line px-5 py-3.5">
          <h2 className="text-sm font-bold text-ink">{title}</h2>
          <button onClick={onClose} className="rounded-lg p-1.5 text-muted hover:bg-slate-100">
            <X size={18} />
          </button>
        </div>
        <div className="p-5">{children}</div>
      </div>
    </div>
  )
}