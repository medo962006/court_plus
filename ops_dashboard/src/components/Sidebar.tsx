import {
  Buildings,
  ChartLine,
  Gear,
  Gauge,
  GitBranch,
  Scroll,
  UserList,
  UsersThree,
} from '@phosphor-icons/react'
import { NavLink } from 'react-router-dom'
import { hasSupabase } from '../lib/supabase'

const links = [
  { to: '/overview', label: 'Overview', icon: Gauge },
  { to: '/pipelines', label: 'CI/CD Pipelines', icon: GitBranch },
  { to: '/logs', label: 'Logs & Errors', icon: Scroll },
  { to: '/courts', label: 'Courts', icon: Buildings },
  { to: '/coaches', label: 'Coaches', icon: UserList },
]

export default function Sidebar() {
  return (
    <aside className="flex h-full w-60 shrink-0 flex-col border-r border-line bg-panel">
      <div className="flex items-center gap-2.5 px-5 pt-6 pb-5">
        <div className="grid h-9 w-9 place-items-center rounded-lg bg-brand-600 text-white">
          <ChartLine size={20} weight="bold" />
        </div>
        <div className="leading-tight">
          <div className="text-sm font-bold text-ink">Court+</div>
          <div className="text-xs font-medium text-muted">Ops Dashboard</div>
        </div>
      </div>

      <nav className="flex-1 space-y-1 px-3">
        {links.map(({ to, label, icon: Icon }) => (
          <NavLink
            key={to}
            to={to}
            className={({ isActive }) => (isActive ? 'nav-item-active' : 'nav-item')}
          >
            <Icon size={18} weight="bold" />
            {label}
          </NavLink>
        ))}
      </nav>

      <div className="border-t border-line p-3">
        {!hasSupabase && (
          <div className="mb-3 rounded-lg bg-amber-50 px-3 py-2.5 text-xs leading-relaxed text-amber-800">
            <div className="mb-1 font-semibold">Stub data</div>
            Connect <code className="rounded bg-white px-1">VITE_SUPABASE_ANON_KEY</code> in
            <code className="ml-1 rounded bg-white px-1">ops_dashboard/.env</code> to go live.
          </div>
        )}
        <div className="flex gap-2 px-1">
          <div className="text-muted">
            <UsersThree size={16} weight="bold" />
          </div>
          <div className="text-muted">
            <Gear size={16} weight="bold" />
          </div>
        </div>
      </div>
    </aside>
  )
}