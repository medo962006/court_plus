// Backend models for court+ app.

// ─── Supabase Config ───

class SupabaseConfig {
  SupabaseConfig._();

  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String anonKey = 'your-anon-key';

  static bool get isConfigured =>
      supabaseUrl != 'https://your-project.supabase.co' &&
      anonKey != 'your-anon-key';
}

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
  static const String payments = 'payments';
}

// ─── Enums ───

enum MatchStatus { upcoming, live, completed, cancelled }
enum BookingStatus { pending, confirmed, cancelled, completed }

// ─── Models ───

class UserProfile {
  final String id;
  final String fullName;
  final String username;
  final String? bio;
  final String? phone;
  final String? email;
  final String? avatarUrl;
  final String? headerUrl;
  final String? dateOfBirth;
  final String? gender;
  final int matchesCount;
  final int courtsCount;
  final int followersCount;
  final int followingCount;
  final String? createdAt;

  const UserProfile({
    required this.id,
    required this.fullName,
    required this.username,
    this.bio,
    this.phone,
    this.email,
    this.avatarUrl,
    this.headerUrl,
    this.dateOfBirth,
    this.gender,
    this.matchesCount = 0,
    this.courtsCount = 0,
    this.followersCount = 0,
    this.followingCount = 0,
    this.createdAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) => UserProfile(
        id: map['id'] as String,
        fullName: map['full_name'] as String? ?? '',
        username: map['username'] as String? ?? '',
        bio: map['bio'] as String?,
        phone: map['phone'] as String?,
        email: map['email'] as String?,
        avatarUrl: map['avatar_url'] as String?,
        headerUrl: map['header_url'] as String?,
        dateOfBirth: map['date_of_birth'] as String?,
        gender: map['gender'] as String?,
        matchesCount: map['matches_count'] as int? ?? 0,
        courtsCount: map['courts_count'] as int? ?? 0,
        followersCount: map['followers_count'] as int? ?? 0,
        followingCount: map['following_count'] as int? ?? 0,
        createdAt: map['created_at'] as String?,
      );
}

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

  factory Court.fromMap(Map<String, dynamic> map) => Court(
        id: map['id'] as String,
        name: map['name'] as String? ?? '',
        center: map['center'] as String? ?? '',
        sportType: map['sport_type'] as String? ?? '',
        location: map['location'] as String? ?? '',
        imageUrl: map['image_url'] as String?,
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        reviewsCount: map['reviews_count'] as int? ?? 0,
        likesCount: map['likes_count'] as int? ?? 0,
        pricePerHour: (map['price_per_hour'] as num?)?.toDouble() ?? 100,
        distance: (map['distance'] as num?)?.toDouble() ?? 0,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
}

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

  factory Booking.fromMap(Map<String, dynamic> map) => Booking(
        id: map['id'] as String,
        userId: map['user_id'] as String? ?? '',
        courtId: map['court_id'] as String? ?? '',
        courtName: map['court_name'] as String? ?? '',
        date: map['date'] as String? ?? '',
        timeSlot: map['time_slot'] as String? ?? '',
        duration: (map['duration'] as num?)?.toDouble() ?? 0,
        totalAmount: (map['total_amount'] as num?)?.toDouble() ?? 0,
        status: BookingStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => BookingStatus.pending),
        paymentMethod: map['payment_method'] as String?,
        addOns: (map['add_ons'] as List?)?.cast<String>() ?? [],
        createdAt: map['created_at'] as String? ?? '',
      );
}

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

  factory Match.fromMap(Map<String, dynamic> map) => Match(
        id: map['id'] as String,
        creatorId: map['creator_id'] as String? ?? '',
        courtId: map['court_id'] as String? ?? '',
        courtName: map['court_name'] as String? ?? '',
        date: map['date'] as String? ?? '',
        timeSlot: map['time_slot'] as String? ?? '',
        level: map['level'] as String? ?? 'beginner',
        gender: map['gender'] as String? ?? 'any',
        location: map['location'] as String? ?? '',
        maxPlayers: map['max_players'] as int? ?? 4,
        currentPlayers: map['current_players'] as int? ?? 1,
        pricePerPerson: (map['price_per_person'] as num?)?.toDouble() ?? 25,
        status: MatchStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => MatchStatus.upcoming),
      );
}