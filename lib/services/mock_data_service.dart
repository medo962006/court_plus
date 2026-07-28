import '../services/models.dart';

/// Mock data service for UI development.
/// Replace with Supabase queries when backend is live.
class MockDataService {
  static final List<Court> courts = [
    Court(
      id: 'c1', name: 'Tennis Outdoor Court A', center: 'Eagle Sport Center',
      sportType: 'Tennis', location: 'King Fahd Rd, Al Olaya, Riyadh',
      rating: 4.5, reviewsCount: 26, likesCount: 273, pricePerHour: 100,
      distance: 1.2, latitude: 24.7136, longitude: 46.6753,
    ),
    Court(
      id: 'c2', name: 'Tennis Indoor Court B', center: 'Riyadh Sports Hub',
      sportType: 'Tennis', location: 'Prince Turkey Rd, Riyadh',
      rating: 4.8, reviewsCount: 42, likesCount: 189, pricePerHour: 150,
      distance: 2.5, latitude: 24.7741, longitude: 46.7376,
    ),
    Court(
      id: 'c3', name: 'Football Pitch 1', center: 'Al Malaz Club',
      sportType: 'Football', location: 'Al Malaz, Riyadh',
      rating: 4.2, reviewsCount: 18, likesCount: 95, pricePerHour: 200,
      distance: 3.0, latitude: 24.6741, longitude: 46.7080,
    ),
    Court(
      id: 'c4', name: 'Tennis Clay Court C', center: 'King Saud University',
      sportType: 'Tennis', location: 'King Saud University, Riyadh',
      rating: 4.6, reviewsCount: 31, likesCount: 147, pricePerHour: 120,
      distance: 4.2, latitude: 24.7212, longitude: 46.6273,
    ),
    Court(
      id: 'c5', name: 'Football Pitch 2', center: 'Al Hilal Club',
      sportType: 'Football', location: 'Al Hilal District, Riyadh',
      rating: 4.0, reviewsCount: 12, likesCount: 63, pricePerHour: 180,
      distance: 5.1, latitude: 24.6541, longitude: 46.6900,
    ),
    Court(
      id: 'c6', name: 'Grand Slam Court', center: 'Riyadh Sports Center',
      sportType: 'Tennis', location: 'King Fahd Rd, Riyadh',
      rating: 4.9, reviewsCount: 58, likesCount: 312, pricePerHour: 250,
      distance: 0.8, latitude: 24.7234, longitude: 46.6789,
    ),
  ];

  static List<Court> filter({
    String? sportType,
    double? minRating,
    String? location,
    String? surface,
    String? query,
  }) {
    var results = courts;
    if (sportType != null && sportType != 'All courts') {
      results = results.where((c) => c.sportType == sportType).toList();
    }
    if (minRating != null) {
      results = results.where((c) => c.rating >= minRating).toList();
    }
    if (location != null && location.isNotEmpty) {
      final q = location.toLowerCase();
      results = results.where((c) => c.location.toLowerCase().contains(q) || c.center.toLowerCase().contains(q)).toList();
    }
    if (surface != null && surface != 'Any') {
      // Surface filtering when data supports it
    }
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      results = results.where((c) =>
          c.name.toLowerCase().contains(q) ||
          c.center.toLowerCase().contains(q) ||
          c.sportType.toLowerCase().contains(q)).toList();
    }
    return results;
  }

  static Court? getCourtById(String id) {
    try {
      return courts.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Time slots available for a given date.
  static List<String> getTimeSlots(DateTime date) {
    // Return different slots based on day of week
    final isWeekend = date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
    if (isWeekend) {
      return ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'];
    }
    return ['14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'];
  }

  static Map<int, bool> getAvailableDays(int year, int month) {
    final days = <int, bool>{};
    final daysInMonth = DateTime(year, month + 1, 0).day;
    for (int d = 1; d <= daysInMonth; d++) {
      // Mark some days as unavailable
      days[d] = d % 7 != 0; // Every 7th day is booked
    }
    return days;
  }
}