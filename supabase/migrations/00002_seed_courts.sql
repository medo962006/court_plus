-- Seed sample courts for court+ platform
insert into public.courts (name, center, sport_type, location, latitude, longitude, rating, reviews_count, likes_count, price_per_hour, is_active)
values
  ('Tennis Outdoor Court A', 'Eagle Sport Center', 'Tennis', 'King Fahd Rd, Al Olaya, Riyadh', 24.7136, 46.6753, 4.5, 26, 273, 100, true),
  ('Tennis Indoor Court B', 'Riyadh Sports Hub', 'Tennis', 'Prince Turkey Rd, Riyadh', 24.7741, 46.7376, 4.8, 42, 189, 150, true),
  ('Football Pitch 1', 'Al Malaz Club', 'Football', 'Al Malaz, Riyadh', 24.6741, 46.7080, 4.2, 18, 95, 200, true),
  ('Tennis Clay Court C', 'King Saud University', 'Tennis', 'King Saud University, Riyadh', 24.7212, 46.6273, 4.6, 31, 147, 120, true),
  ('Football Pitch 2', 'Al Hilal Club', 'Football', 'Al Hilal District, Riyadh', 24.6541, 46.6900, 4.0, 12, 63, 180, true),
  ('Grand Slam Court', 'Riyadh Sports Center', 'Tennis', 'King Fahd Rd, Riyadh', 24.7234, 46.6789, 4.9, 58, 312, 250, true)
on conflict do nothing;