#!/usr/bin/env python3
"""Seed initial data into Supabase courts table."""
import json
import urllib.request
import urllib.error

SUPABASE_URL = "https://fnyekgsajrrihefqyaiq.supabase.co"
ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZueWVrZ3NhanJyaWhlZnF5YWlxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODUzMTk5MDQsImV4cCI6MjEwMDg5NTkwNH0.8SemE6GbtZ0YvxD1XwzGstIDxTtDq9YIpHF0G_pqUSc"

HEADERS = {
    "apikey": ANON_KEY,
    "Authorization": f"Bearer {ANON_KEY}",
    "Content-Type": "application/json",
    "Prefer": "return=minimal",
}

courts = [
    {"name": "Tennis Outdoor Court A", "center": "Eagle Sport Center", "sport_type": "Tennis",
     "location": "King Fahd Rd, Al Olaya, Riyadh", "latitude": 24.7136, "longitude": 46.6753,
     "rating": 4.5, "reviews_count": 26, "likes_count": 273, "price_per_hour": 100, "is_active": True},
    {"name": "Tennis Indoor Court B", "center": "Riyadh Sports Hub", "sport_type": "Tennis",
     "location": "Prince Turkey Rd, Riyadh", "latitude": 24.7741, "longitude": 46.7376,
     "rating": 4.8, "reviews_count": 42, "likes_count": 189, "price_per_hour": 150, "is_active": True},
    {"name": "Football Pitch 1", "center": "Al Malaz Club", "sport_type": "Football",
     "location": "Al Malaz, Riyadh", "latitude": 24.6741, "longitude": 46.7080,
     "rating": 4.2, "reviews_count": 18, "likes_count": 95, "price_per_hour": 200, "is_active": True},
    {"name": "Tennis Clay Court C", "center": "King Saud University", "sport_type": "Tennis",
     "location": "King Saud University, Riyadh", "latitude": 24.7212, "longitude": 46.6273,
     "rating": 4.6, "reviews_count": 31, "likes_count": 147, "price_per_hour": 120, "is_active": True},
    {"name": "Football Pitch 2", "center": "Al Hilal Club", "sport_type": "Football",
     "location": "Al Hilal District, Riyadh", "latitude": 24.6541, "longitude": 46.6900,
     "rating": 4.0, "reviews_count": 12, "likes_count": 63, "price_per_hour": 180, "is_active": True},
    {"name": "Grand Slam Court", "center": "Riyadh Sports Center", "sport_type": "Tennis",
     "location": "King Fahd Rd, Riyadh", "latitude": 24.7234, "longitude": 46.6789,
     "rating": 4.9, "reviews_count": 58, "likes_count": 312, "price_per_hour": 250, "is_active": True},
]

url = f"{SUPABASE_URL}/rest/v1/courts"
success = 0
failed = 0

for court in courts:
    data = json.dumps(court).encode("utf-8")
    req = urllib.request.Request(url, data=data, headers=HEADERS, method="POST")
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            print(f"✅ {court['name']}")
            success += 1
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"❌ {court['name']}: HTTP {e.code} {body[:100]}")
        failed += 1

print(f"\nSeeded: {success} success, {failed} failed")