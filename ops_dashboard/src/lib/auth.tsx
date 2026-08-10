import type { Session, User } from '@supabase/supabase-js'
import {
  createContext,
  useContext,
  useEffect,
  useState,
  type ReactNode,
} from 'react'
import { hasSupabase, supabase } from './supabase'
import type { Profile } from './types'

interface AuthState {
  session: Session | null
  user: User | null
  profile: Profile | null
  isAdmin: boolean
  loading: boolean
  signIn: (email: string, password: string) => Promise<string | null>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthState | null>(null)

const loadProfile = async (user: User) => {
  const { data } = await supabase!
    .from('profiles')
    .select('id,email,username,full_name,role')
    .eq('id', user.id)
    .maybeSingle()
  return (data as Profile) ?? null
}

export function AuthProvider({ children }: { children: ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [user, setUser] = useState<User | null>(null)
  const [profile, setProfile] = useState<Profile | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (!hasSupabase) {
      setLoading(false)
      return
    }
    let alive = true
    supabase!.auth.getSession().then(async ({ data }) => {
      if (!alive) return
      setSession(data.session)
      setUser(data.session?.user ?? null)
      if (data.session?.user) setProfile(await loadProfile(data.session.user))
      setLoading(false)
    })
    const { data: sub } = supabase!.auth.onAuthStateChange(async (_evt, s) => {
      if (!alive) return
      setSession(s)
      setUser(s?.user ?? null)
      setProfile(s?.user ? await loadProfile(s.user) : null)
    })
    return () => {
      alive = false
      sub.subscription.unsubscribe()
    }
  }, [])

  const value: AuthState = {
    session,
    user,
    profile,
    isAdmin: profile?.role === 'admin',
    loading,
    signIn: async (email, password) => {
      const { error } = await supabase!.auth.signInWithPassword({ email, password })
      return error?.message ?? null
    },
    signOut: async () => {
      await supabase!.auth.signOut()
    },
  }

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}