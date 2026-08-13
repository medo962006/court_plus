import { Pencil, Plus, Star, UserCircle } from '@phosphor-icons/react'
import { useState } from 'react'
import Modal from '../components/Modal'
import { Badge, StatusPill } from '../components/ui'
import { api } from '../lib/api'
import { useAuth } from '../lib/auth'
import { useAsync } from '../lib/hooks'
import type { Coach } from '../lib/types'

const emptyForm = {
  full_name: '',
  username: '',
  sport_type: 'Tennis',
  price_per_session: 100,
  experience: 0,
  bio: '',
}

export default function Coaches() {
  const { data } = useAsync(() => api.coaches())
  const { isAdmin } = useAuth()
  const [coaches, setCoaches] = useState<Coach[]>(data ?? [])
  const [editing, setEditing] = useState<Coach | null>(null)
  const [creating, setCreating] = useState(false)
  const [form, setForm] = useState(emptyForm)
  const [saving, setSaving] = useState(false)
  const [saveError, setSaveError] = useState<string | null>(null)

  const list = coaches.length ? coaches : data ?? []

  const openCreate = () => {
    setForm(emptyForm)
    setSaveError(null)
    setCreating(true)
  }
  const openEdit = (c: Coach) => {
    setForm({
      full_name: c.full_name,
      username: c.username,
      sport_type: c.sport_type,
      price_per_session: c.price_per_session,
      experience: c.experience,
      bio: c.bio ?? '',
    })
    setEditing(c)
  }

  const toggleActive = async (c: Coach) => {
    const updated = await api.updateCoach(c.id, { is_active: !c.is_active })
    setCoaches((prev) => prev.map((x) => (x.id === updated.id ? updated : x)))
  }

  const save = async () => {
    setSaving(true)
    setSaveError(null)
    try {
      const payload = {
        full_name: form.full_name,
        username: form.username,
        sport_type: form.sport_type,
        price_per_session: Number(form.price_per_session),
        experience: Number(form.experience),
        bio: form.bio || null,
      }
      const saved = editing ? await api.updateCoach(editing.id, payload) : await api.createCoach(payload)
      if (editing) {
        setCoaches((prev) => prev.map((x) => (x.id === saved.id ? saved : x)))
      } else {
        setCoaches((prev) => [saved, ...prev])
      }
      setCreating(false)
      setEditing(null)
    } catch (e) {
      setSaveError((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const set =
    (k: keyof typeof emptyForm) =>
    (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) =>
      setForm((f) => ({ ...f, [k]: e.target.value }))

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted">{list.length} coaches</p>
        {isAdmin ? (
          <button className="btn-primary" onClick={openCreate}>
            <Plus size={16} weight="bold" /> Add coach
          </button>
        ) : (
          <span className="text-xs font-semibold text-amber-700 dark:text-amber-400">Read-only · admin rights required</span>
        )}
      </div>
      {!isAdmin && (
        <div className="rounded-lg bg-amber-50 px-4 py-2.5 text-xs font-medium dark:bg-amber-500/15 text-amber-800 dark:text-amber-200">
          You're signed in as a non-admin — coach changes are reserved for admins.
        </div>
      )}

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-line">
              <th className="th">Coach</th>
              <th className="th">Sport</th>
              <th className="th">Price/session</th>
              <th className="th">Experience</th>
              <th className="th">Rating</th>
              <th className="th">Status</th>
              <th className="th w-24 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {list.map((c) => (
              <tr key={c.id} className="border-b border-line/60 last:border-0 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                <td className="td">
                  <div className="flex items-center gap-2.5">
                    {c.avatar_url ? (
                      <img src={c.avatar_url} alt="" className="h-8 w-8 rounded-full object-cover" />
                    ) : (
                      <UserCircle size={32} className="text-slate-300" weight="light" />
                    )}
                    <div>
                      <div className="font-semibold text-ink">{c.full_name}</div>
                      <div className="text-xs text-muted">@{c.username}</div>
                    </div>
                  </div>
                </td>
                <td className="td">
                  <Badge tone="sky">{c.sport_type}</Badge>
                </td>
                <td className="td">SAR {c.price_per_session}</td>
                <td className="td">{c.experience} yrs</td>
                <td className="td">
                  <span className="inline-flex items-center gap-1">
                    <Star size={14} className="text-amber-500" weight="fill" /> {c.rating}
                  </span>
                </td>
                <td className="td">
                  <button onClick={() => toggleActive(c)}>
                    <StatusPill status={c.is_active ? 'healthy' : 'down'} />
                  </button>
                </td>
                <td className="td text-right">
                  <button
                    onClick={() => openEdit(c)}
                    className="rounded-lg p-1.5 text-muted hover:bg-slate-100"
                  >
                    <Pencil size={16} />
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      <Modal
        open={creating || !!editing}
        title={editing ? `Edit ${editing.full_name}` : 'Add coach'}
        onClose={() => {
          setCreating(false)
          setEditing(null)
        }}
      >
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Full name</span>
            <input className="input" value={form.full_name} onChange={set('full_name')} placeholder="Sarah Ahmed" />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Username</span>
            <input className="input" value={form.username} onChange={set('username')} placeholder="sarahahmed" />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Sport</span>
            <select className="input" value={form.sport_type} onChange={set('sport_type')}>
              {['Tennis', 'Football', 'Padel', 'Basketball', 'Cricket'].map((s) => (
                <option key={s}>{s}</option>
              ))}
            </select>
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Price / session (SAR)</span>
            <input className="input" type="number" value={form.price_per_session} onChange={set('price_per_session')} />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Experience (yrs)</span>
            <input className="input" type="number" value={form.experience} onChange={set('experience')} />
          </label>
          <label className="sm:col-span-2">
            <span className="mb-1 block text-xs font-semibold text-muted">Bio</span>
            <textarea className="input" rows={3} value={form.bio} onChange={set('bio')} placeholder="Short bio…" />
          </label>
        </div>
        <div className="mt-5 flex flex-col gap-2">
          {saveError && (
            <div className="rounded-lg bg-red-50 px-3 py-2 text-xs font-medium text-red-600 dark:bg-red-500/15 dark:text-red-300">
              {saveError}
            </div>
          )}
          <div className="flex justify-end gap-2">
            <button
              className="btn-ghost"
              onClick={() => {
                setCreating(false)
                setEditing(null)
              }}
            >
              Cancel
            </button>
            <button className="btn-primary" onClick={save} disabled={saving || !isAdmin}>
              {saving ? 'Saving…' : 'Save'}
            </button>
          </div>
        </div>
      </Modal>
    </div>
  )
}