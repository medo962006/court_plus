-- Court+ Ops — admin bootstrap & audit logging
-- - Allow admins to write to admin_audit_log.
-- - promote_first_admin: one-time bootstrap (no-op once an admin exists).
-- Apply:  supabase db push

-- 1. Admins may record audit entries (client-side, as themselves).
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies
    WHERE tablename = 'admin_audit_log' AND policyname = 'admin_audit_log_insert'
  ) THEN
    CREATE POLICY "admin_audit_log_insert" ON public.admin_audit_log
      FOR INSERT TO authenticated WITH CHECK (public.is_admin());
  END IF;
END $$;

-- 2. One-time bootstrap: promotes the first account to admin. Refuses once
--    an admin exists, so leaving it executable is safe.
CREATE OR REPLACE FUNCTION public.promote_first_admin(target_email text)
RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE did boolean;
BEGIN
  IF EXISTS (SELECT 1 FROM public.profiles WHERE role = 'admin') THEN
    RETURN false; -- already bootstrapped; refuse
  END IF;
  UPDATE public.profiles SET role = 'admin' WHERE email = target_email
  RETURNING true INTO did;
  RETURN COALESCE(did, false);
END $$;
GRANT EXECUTE ON FUNCTION public.promote_first_admin(text) TO anon, authenticated;

-- 3. Admins promote other staff members later.
CREATE OR REPLACE FUNCTION public.admin_promote(target_email text)
RETURNS boolean
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE did boolean;
BEGIN
  IF NOT public.is_admin() THEN RETURN false; END IF;
  UPDATE public.profiles SET role = 'admin' WHERE email = target_email
  RETURNING true INTO did;
  RETURN COALESCE(did, false);
END $$;
GRANT EXECUTE ON FUNCTION public.admin_promote(text) TO authenticated;