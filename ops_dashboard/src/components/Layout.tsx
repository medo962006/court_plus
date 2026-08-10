import { Outlet, useLocation } from 'react-router-dom'
import Sidebar from './Sidebar'
import Topbar from './Topbar'

const titles: Record<string, string> = {
  '/overview': 'System Overview',
  '/pipelines': 'CI/CD Pipelines',
  '/logs': 'Logs & Errors',
  '/courts': 'Courts',
  '/coaches': 'Coaches',
}

export default function Layout() {
  const { pathname } = useLocation()
  const title = titles[pathname] ?? 'Court+'

  return (
    <div className="flex h-full w-full">
      <Sidebar />
      <div className="flex min-w-0 flex-1 flex-col">
        <Topbar title={title} />
        <main className="flex-1 overflow-y-auto p-6">
          <Outlet />
        </main>
      </div>
    </div>
  )
}