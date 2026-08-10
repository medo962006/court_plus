#!/usr/bin/env python3
"""Execute migration SQL on Supabase via the exec_sql RPC endpoint."""
import json
import urllib.request
import urllib.error

SUPABASE_URL = "https://fnyekgsajrrihefqyaiq.supabase.co"
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZueWVrZ3NhanJyaWhlZnF5YWlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUzMTk5MDQsImV4cCI6MjEwMDg5NTkwNH0.8SemE6GbtZ0YvxD1XwzGstIDxTtDq9YIpHF0G_pqUSc"

with open("supabase/migrations/001_initial_schema.sql", "r", encoding="utf-8") as f:
    sql = f.read()

# Try direct SQL execution via the pg_dump endpoint or raw Supabase SQL API
# First check if the service accepts exec_sql
endpoints = [
    f"{SUPABASE_URL}/rest/v1/rpc/exec_sql",
    f"{SUPABASE_URL}/supabase/v1/sql",
]

headers = {
    "apikey": ANON_KEY,
    "Authorization": f"Bearer {ANON_KEY}",
    "Content-Type": "application/json",
}

payload = json.dumps({"query": sql}).encode("utf-8")

for endpoint in endpoints:
    req = urllib.request.Request(endpoint, data=payload, headers=headers, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            body = resp.read().decode("utf-8")
            print(f"SUCCESS ({endpoint}): HTTP {resp.status}")
            print(body[:500])
            # If we got here, it worked
            exit(0)
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"FAILED ({endpoint}): HTTP {e.code}")
        if "PGRST106" in body or "not found" in body.lower():
            continue  # try next endpoint
        print(body[:500])
    except Exception as e:
        print(f"ERROR ({endpoint}): {e}")

print("\n--- Could not execute SQL via REST API. ---")
print("You may need the service_role key or Supabase Management API token.")
print("Alternative: paste migration SQL into Supabase Dashboard > SQL Editor.")
exit(1)