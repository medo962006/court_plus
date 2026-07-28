import 'package:flutter_test/flutter_test.dart';
import 'package:court_plus/services/models.dart';

void main() {
  group('UserProfile', () {
    test('fromMap creates instance with all fields', () {
      final map = <String, dynamic>{
        'id': 'user-1',
        'full_name': 'John Doe',
        'username': 'johndoe',
        'bio': 'Love tennis',
        'phone': '+1234567890',
        'email': 'john@example.com',
        'avatar_url': 'https://example.com/avatar.jpg',
        'header_url': 'https://example.com/header.jpg',
        'date_of_birth': '15 / 05 / 1990',
        'gender': 'male',
        'matches_count': 42,
        'courts_count': 5,
        'followers_count': 100,
        'following_count': 50,
        'created_at': '2025-01-01T00:00:00Z',
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.id, 'user-1');
      expect(profile.fullName, 'John Doe');
      expect(profile.username, 'johndoe');
      expect(profile.bio, 'Love tennis');
      expect(profile.phone, '+1234567890');
      expect(profile.email, 'john@example.com');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
      expect(profile.headerUrl, 'https://example.com/header.jpg');
      expect(profile.dateOfBirth, '15 / 05 / 1990');
      expect(profile.gender, 'male');
      expect(profile.matchesCount, 42);
      expect(profile.courtsCount, 5);
      expect(profile.followersCount, 100);
      expect(profile.followingCount, 50);
      expect(profile.createdAt, '2025-01-01T00:00:00Z');
    });

    test('fromMap with missing fields uses defaults', () {
      final map = <String, dynamic>{
        'id': 'user-2',
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.id, 'user-2');
      expect(profile.fullName, '');
      expect(profile.username, '');
      expect(profile.bio, isNull);
      expect(profile.phone, isNull);
      expect(profile.email, isNull);
      expect(profile.avatarUrl, isNull);
      expect(profile.headerUrl, isNull);
      expect(profile.dateOfBirth, isNull);
      expect(profile.gender, isNull);
      expect(profile.matchesCount, 0);
      expect(profile.courtsCount, 0);
      expect(profile.followersCount, 0);
      expect(profile.followingCount, 0);
      expect(profile.createdAt, isNull);
    });

    test('fromMap with null fields uses defaults', () {
      final map = <String, dynamic>{
        'id': 'user-3',
        'full_name': null,
        'username': null,
        'bio': null,
        'matches_count': null,
      };

      final profile = UserProfile.fromMap(map);

      expect(profile.fullName, '');
      expect(profile.username, '');
      expect(profile.bio, isNull);
      expect(profile.matchesCount, 0);
    });
  });

  group('Court', () {
    test('fromMap creates instance with all fields including coordinates', () {
      final map = <String, dynamic>{
        'id': 'court-1',
        'name': 'Central Tennis Court',
        'center': 'Sports Center',
        'sport_type': 'tennis',
        'location': '123 Main St',
        'image_url': 'https://example.com/court.jpg',
        'rating': 4.5,
        'reviews_count': 120,
        'likes_count': 300,
        'price_per_hour': 50.0,
        'distance': 2.3,
        'latitude': 40.7128,
        'longitude': -74.0060,
      };

      final court = Court.fromMap(map);

      expect(court.id, 'court-1');
      expect(court.name, 'Central Tennis Court');
      expect(court.center, 'Sports Center');
      expect(court.sportType, 'tennis');
      expect(court.location, '123 Main St');
      expect(court.imageUrl, 'https://example.com/court.jpg');
      expect(court.rating, 4.5);
      expect(court.reviewsCount, 120);
      expect(court.likesCount, 300);
      expect(court.pricePerHour, 50.0);
      expect(court.distance, 2.3);
      expect(court.latitude, 40.7128);
      expect(court.longitude, -74.0060);
    });

    test('fromMap with partial fields uses defaults', () {
      final map = <String, dynamic>{
        'id': 'court-2',
        'name': 'Basic Court',
      };

      final court = Court.fromMap(map);

      expect(court.id, 'court-2');
      expect(court.name, 'Basic Court');
      expect(court.center, '');
      expect(court.sportType, '');
      expect(court.location, '');
      expect(court.imageUrl, isNull);
      expect(court.rating, 0);
      expect(court.reviewsCount, 0);
      expect(court.likesCount, 0);
      expect(court.pricePerHour, 100);
      expect(court.distance, 0);
      expect(court.latitude, isNull);
      expect(court.longitude, isNull);
    });

    test('fromMap parses numeric fields from int', () {
      final map = <String, dynamic>{
        'id': 'court-3',
        'name': 'Int Court',
        'rating': 4,
        'price_per_hour': 75,
        'distance': 1,
      };

      final court = Court.fromMap(map);

      expect(court.rating, 4.0);
      expect(court.pricePerHour, 75.0);
      expect(court.distance, 1.0);
    });
  });

  group('Booking', () {
    test('fromMap creates instance with all fields and confirmed status', () {
      final map = <String, dynamic>{
        'id': 'booking-1',
        'user_id': 'user-1',
        'court_id': 'court-1',
        'court_name': 'Central Court',
        'date': '2025-06-15',
        'time_slot': '10:00-11:00',
        'duration': 1.5,
        'total_amount': 75.0,
        'status': 'confirmed',
        'payment_method': 'credit_card',
        'add_ons': ['racket', 'water'],
        'created_at': '2025-06-01T00:00:00Z',
      };

      final booking = Booking.fromMap(map);

      expect(booking.id, 'booking-1');
      expect(booking.userId, 'user-1');
      expect(booking.courtId, 'court-1');
      expect(booking.courtName, 'Central Court');
      expect(booking.date, '2025-06-15');
      expect(booking.timeSlot, '10:00-11:00');
      expect(booking.duration, 1.5);
      expect(booking.totalAmount, 75.0);
      expect(booking.status, BookingStatus.confirmed);
      expect(booking.paymentMethod, 'credit_card');
      expect(booking.addOns, ['racket', 'water']);
      expect(booking.createdAt, '2025-06-01T00:00:00Z');
    });

    test('fromMap parses all booking statuses', () {
      for (final status in BookingStatus.values) {
        final map = <String, dynamic>{
          'id': 'b-${status.name}',
          'user_id': 'u1',
          'court_id': 'c1',
          'court_name': 'Court',
          'date': '2025-01-01',
          'time_slot': '09:00',
          'duration': 1,
          'total_amount': 50,
          'status': status.name,
        };
        final booking = Booking.fromMap(map);
        expect(booking.status, status,
            reason: 'Expected ${status.name} but got ${booking.status.name}');
      }
    });

    test('fromMap defaults to pending for unknown status', () {
      final map = <String, dynamic>{
        'id': 'b-unknown',
        'status': 'unknown_status',
      };

      final booking = Booking.fromMap(map);

      expect(booking.status, BookingStatus.pending);
    });

    test('fromMap with missing fields uses defaults', () {
      final map = <String, dynamic>{
        'id': 'booking-min',
      };

      final booking = Booking.fromMap(map);

      expect(booking.id, 'booking-min');
      expect(booking.userId, '');
      expect(booking.courtId, '');
      expect(booking.courtName, '');
      expect(booking.date, '');
      expect(booking.timeSlot, '');
      expect(booking.duration, 0);
      expect(booking.totalAmount, 0);
      expect(booking.status, BookingStatus.pending);
      expect(booking.paymentMethod, isNull);
      expect(booking.addOns, []);
      expect(booking.createdAt, '');
    });
  });

  group('Match', () {
    test('fromMap creates instance with all fields', () {
      final map = <String, dynamic>{
        'id': 'match-1',
        'creator_id': 'user-1',
        'court_id': 'court-1',
        'court_name': 'Central Court',
        'date': '2025-06-20',
        'time_slot': '18:00-19:00',
        'level': 'intermediate',
        'gender': 'mixed',
        'location': 'Court 3',
        'max_players': 4,
        'current_players': 2,
        'price_per_person': 30.0,
        'status': 'upcoming',
      };

      final match = Match.fromMap(map);

      expect(match.id, 'match-1');
      expect(match.creatorId, 'user-1');
      expect(match.courtId, 'court-1');
      expect(match.courtName, 'Central Court');
      expect(match.date, '2025-06-20');
      expect(match.timeSlot, '18:00-19:00');
      expect(match.level, 'intermediate');
      expect(match.gender, 'mixed');
      expect(match.location, 'Court 3');
      expect(match.maxPlayers, 4);
      expect(match.currentPlayers, 2);
      expect(match.pricePerPerson, 30.0);
      expect(match.status, MatchStatus.upcoming);
    });

    test('fromMap parses all match statuses', () {
      for (final status in MatchStatus.values) {
        final map = <String, dynamic>{
          'id': 'm-${status.name}',
          'creator_id': 'u1',
          'court_id': 'c1',
          'court_name': 'Court',
          'date': '2025-01-01',
          'time_slot': '09:00',
          'level': 'beginner',
          'gender': 'any',
          'location': 'Loc',
          'status': status.name,
        };
        final match = Match.fromMap(map);
        expect(match.status, status,
            reason: 'Expected ${status.name} but got ${match.status.name}');
      }
    });

    test('fromMap defaults level and gender', () {
      final map = <String, dynamic>{
        'id': 'match-min',
        'creator_id': 'u1',
        'court_id': 'c1',
        'court_name': 'Court',
        'date': '2025-01-01',
        'time_slot': '09:00',
        'location': 'Loc',
      };

      final match = Match.fromMap(map);

      expect(match.level, 'beginner');
      expect(match.gender, 'any');
      expect(match.maxPlayers, 4);
      expect(match.currentPlayers, 1);
      expect(match.pricePerPerson, 25.0);
      expect(match.status, MatchStatus.upcoming);
    });

    test('fromMap defaults to upcoming for unknown status', () {
      final map = <String, dynamic>{
        'id': 'm-bad',
        'creator_id': 'u1',
        'court_id': 'c1',
        'court_name': 'Court',
        'date': '2025-01-01',
        'time_slot': '09:00',
        'level': 'beginner',
        'gender': 'any',
        'location': 'Loc',
        'status': 'bogus',
      };

      final match = Match.fromMap(map);
      expect(match.status, MatchStatus.upcoming);
    });
  });
}