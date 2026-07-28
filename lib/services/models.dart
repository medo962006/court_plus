// Backend models for court+ app.
class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';

  static bool get isConfigured =>
      supabaseUrl != 'https://your-project.supabase.co' &&
      anonKey != 'your-anon-key';
}

/// Supabase table names.
class DbTables {
  DbTables._();

  static const String users = 'users';
  static const String courts = 'courts';
  static const String bookings = 'bookings';
  static const String matches = 'matches';
  static const String invitations = 'match_invitations';
  static const String reviews = 'reviews';
  static const String moments = 'moments';
  static const String notifications = 'notifications';
}

/// Enum for match status.
enum MatchStatus { upcoming, live, completed, cancelled }

/// Enum for booking status.
enum BookingStatus { pending, confirmed, cancelled, completed }

/// User profile model.
class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String? bio;
  final String? phone;
  final String? avatarUrl;
  final String? headerUrl;
  final String? dateOfBirth;
  final String? gender;
  final int matchesCount;
  final int courtsCount;
  final int followersCount;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    this.bio,
    this.phone,
    this.avatarUrl,
    this.headerUrl,
    this.dateOfBirth,
    this.gender,
    this.matchesCount = 0,
    this.courtsCount = 0,
    this.followersCount = 0,
  });
}

/// Court model.
class Court {
  final String id;
  final String name;
  final String center;
  final String sportType;
  final String location;
  final String? imageUrl;
  final double rating;
  final int reviewsCount;
  final int likesCount;
  final double pricePerHour;
  final double distance;
  final double? latitude;
  final double? longitude;

  const Court({
    required this.id,
    required this.name,
    required this.center,
    required this.sportType,
    required this.location,
    this.imageUrl,
    this.rating = 0,
    this.reviewsCount = 0,
    this.likesCount = 0,
    this.pricePerHour = 100,
    this.distance = 0,
    this.latitude,
    this.longitude,
  });
}

/// Booking model.
class Booking {
  final String id;
  final String userId;
  final String courtId;
  final String courtName;
  final String date;
  final String timeSlot;
  final double duration;
  final double totalAmount;
  final BookingStatus status;
  final String? paymentMethod;
  final List<String> addOns;
  final String createdAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.timeSlot,
    required this.duration,
    required this.totalAmount,
    this.status = BookingStatus.pending,
    this.paymentMethod,
    this.addOns = const [],
    this.createdAt = '',
  });
}

/// Match model.
class Match {
  final String id;
  final String creatorId;
  final String courtId;
  final String courtName;
  final String date;
  final String timeSlot;
  final String level;
  final String gender;
  final String location;
  final int maxPlayers;
  final int currentPlayers;
  final double pricePerPerson;
  final MatchStatus status;

  const Match({
    required this.id,
    required this.creatorId,
    required this.courtId,
    required this.courtName,
    required this.date,
    required this.timeSlot,
    required this.level,
    required this.gender,
    required this.location,
    this.maxPlayers = 4,
    this.currentPlayers = 1,
    this.pricePerPerson = 25,
    this.status = MatchStatus.upcoming,
  });
}