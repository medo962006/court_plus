import { MapPin, Pencil, Plus, Star } from '@phosphor-icons/react'
import { useState } from 'react'
import Modal from '../components/Modal'
import { Badge, StatusPill } from '../components/ui'
import { api } from '../lib/api'
import { useAuth } from '../lib/auth'
import { useAsync } from '../lib/hooks'
import type { Court } from '../lib/types'

const emptyForm = {
  name: '',
  center: '',
  sport_type: 'Tennis',
  location: '',
  address: '',
  price_per_hour: 100,
  latitude: '',
  longitude: '',
}

export default function Courts() {
  const { data } = useAsync(() => api.courts())
  const { isAdmin } = useAuth()
  const [courts, setCourts] = useState<Court[]>(data ?? [])
  const [editing, setEditing] = useState<Court | null>(null)
  const [creating, setCreating] = useState(false)
  const [form, setForm] = useState(emptyForm)
  const [saving, setSaving] = useState(false)
  const [saveError, setSaveError] = useState<string | null>(null)

  const list = courts.length ? courts : data ?? []

  const openCreate = () => {
    setForm(emptyForm)
    setSaveError(null)
    setCreating(true)
  }
  const openEdit = (c: Court) => {
    setForm({
      name: c.name,
      center: c.center,
      sport_type: c.sport_type,
      location: c.location,
      address: c.address ?? '',
      price_per_hour: c.price_per_hour,
      latitude: c.latitude?.toString() ?? '',
      longitude: c.longitude?.toString() ?? '',
    })
    setEditing(c)
  }

  const toggleActive = async (c: Court) => {
    const updated = await api.updateCourt(c.id, { is_active: !c.is_active })
    setCourts((prev) => prev.map((x) => (x.id === updated.id ? updated : x)))
  }

  const save = async () => {
    setSaving(true)
    setSaveError(null)
    try {
      const payload = {
        name: form.name,
        center: form.center,
        sport_type: form.sport_type,
        location: form.location,
        address: form.address || null,
        price_per_hour: Number(form.price_per_hour),
        latitude: form.latitude ? Number(form.latitude) : null,
        longitude: form.longitude ? Number(form.longitude) : null,
      }
      const saved = editing ? await api.updateCourt(editing.id, payload) : await api.createCourt(payload)
      if (editing) {
        setCourts((prev) => prev.map((x) => (x.id === saved.id ? saved : x)))
      } else {
        setCourts((prev) => [saved, ...prev])
      }
      setCreating(false)
      setEditing(null)
    } catch (e) {
      setSaveError((e as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const set = (k: keyof typeof emptyForm) => (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement>) =>
    setForm((f) => ({ ...f, [k]: e.target.value }))

  return (
    <div className="space-y-4">
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted">{list.length} courts across all centers</p>
        {isAdmin ? (
          <button className="btn-primary" onClick={openCreate}>
            <Plus size={16} weight="bold" /> Add court
          </button>
        ) : (
          <span className="text-xs font-semibold text-amber-700 dark:text-amber-400">Read-only · admin rights required</span>
        )}
      </div>
      {!isAdmin && (
        <div className="rounded-lg bg-amber-50 px-4 py-2.5 text-xs font-medium dark:bg-amber-500/15 text-amber-800 dark:text-amber-200">
          You're signed in as a non-admin — court changes are reserved for admins.
        </div>
      )}

      <div className="card overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="border-b border-line">
              <th className="th">Court</th>
              <th className="th">Sport</th>
              <th className="th">Location</th>
              <th className="th">Price/hr</th>
              <th className="th">Rating</th>
              <th className="th">Status</th>
              <th className="th w-24 text-right">Actions</th>
            </tr>
          </thead>
          <tbody>
            {list.map((c) => (
              <tr key={c.id} className="border-b border-line/60 last:border-0 hover:bg-slate-50 dark:hover:bg-slate-800/50">
                <td className="td">
                  <div className="font-semibold text-ink">{c.name}</div>
                  <div className="text-xs text-muted">{c.center}</div>
                </td>
                <td className="td">
                  <Badge tone="sky">{c.sport_type}</Badge>
                </td>
                <td className="td">
                  <span className="inline-flex items-center gap-1 text-sm">
                    <MapPin size={14} className="text-muted" /> {c.location}
                  </span>
                </td>
                <td className="td">SAR {c.price_per_hour}</td>
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
        title={editing ? `Edit ${editing.name}` : 'Add court'}
        onClose={() => {
          setCreating(false)
          setEditing(null)
        }}
      >
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <label className="sm:col-span-2">
            <span className="mb-1 block text-xs font-semibold text-muted">Name</span>
            <input className="input" value={form.name} onChange={set('name')} placeholder="Riyadh Court 1" />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Center</span>
            <input className="input" value={form.center} onChange={set('center')} placeholder="King Abdullah Park" />
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
            <span className="mb-1 block text-xs font-semibold text-muted">Location</span>
            <input className="input" value={form.location} onChange={set('location')} placeholder="Riyadh" />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Address</span>
            <input className="input" value={form.address} onChange={set('address')} placeholder="Olaya St" />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Price / hour (SAR)</span>
            <input className="input" type="number" value={form.price_per_hour} onChange={set('price_per_hour')} />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Latitude</span>
            <input className="input" value={form.latitude} onChange={set('latitude')} placeholder="24.7200" />
          </label>
          <label>
            <span className="mb-1 block text-xs font-semibold text-muted">Longitude</span>
            <input className="input" value={form.longitude} onChange={set('longitude')} placeholder="46.6700" />
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