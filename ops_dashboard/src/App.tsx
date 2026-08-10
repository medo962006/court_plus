import { Navigate, Outlet, Route, Routes, useLocation } from 'react-router-dom'
import Layout from './components/Layout'
import Overview from './pages/Overview'
import Pipelines from './pages/Pipelines'
import Logs from './pages/Logs'
import Courts from './pages/Courts'
import Coaches from './pages/Coaches'
import Login from './pages/Login'
import { AuthProvider, useAuth } from './lib/auth'
import { hasSupabase } from './lib/supabase'

function RequireAuth() {
  const { loading, session } = useAuth()
  const location = useLocation()
  if (loading) {
    return (
      <div className="grid h-full w-full place-items-center text-sm text-muted">Loading…</div>
    )
  }
  // Stub mode (no Supabase credentials): open, so the UI stays reviewable.
  if (!hasSupabase) return <Outlet />
  if (!session) return <Navigate to="/login" replace state={{ from: location.pathname }} />
  return <Outlet />
}

export default function App() {
  return (
    <AuthProvider>
      <Routes>
        <Route path="/login" element={<Login />} />
        <Route element={<RequireAuth />}>
          <Route element={<Layout />}>
            <Route index element={<Navigate to="/overview" replace />} />
            <Route path="/overview" element={<Overview />} />
            <Route path="/pipelines" element={<Pipelines />} />
            <Route path="/logs" element={<Logs />} />
            <Route path="/courts" element={<Courts />} />
            <Route path="/coaches" element={<Coaches />} />
            <Route path="*" element={<Navigate to="/overview" replace />} />
          </Route>
        </Route>
      </Routes>
    </AuthProvider>
  )
}