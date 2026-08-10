// Backend models for court+ app.

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
  static const String favorites = 'favorites';
  static const String follows = 'follows';
  static const String momentLikes = 'moment_likes';
  static const String momentComments = 'moment_comments';
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

    UserProfile copyWith({
      String? id,
      String? fullName,
      String? username,
      String? bio,
      String? phone,
      String? email,
      String? avatarUrl,
      String? headerUrl,
      String? dateOfBirth,
      String? gender,
      int? matchesCount,
      int? courtsCount,
      int? followersCount,
      int? followingCount,
      String? createdAt,
    }) => UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      username: username ?? this.username,
      bio: bio ?? this.bio,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      headerUrl: headerUrl ?? this.headerUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      matchesCount: matchesCount ?? this.matchesCount,
      courtsCount: courtsCount ?? this.courtsCount,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      createdAt: createdAt ?? this.createdAt,
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
    final String? surfaceType;
    final List<dynamic> amenities;

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
      this.surfaceType,
      this.amenities = const [],
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
          surfaceType: map['surface_type'] as String?,
          amenities: (map['amenities'] as List?) ?? [],
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

class NotificationItem {
  final String id;
  final String userId;
  final String type;
  final String? title;
  final String? body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    this.title,
    this.body,
    this.data,
    this.isRead = false,
    this.createdAt = '',
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) => NotificationItem(
        id: map['id'] as String,
        userId: map['user_id'] as String? ?? '',
        type: map['type'] as String? ?? 'general',
        title: map['title'] as String?,
        body: map['body'] as String?,
        data: map['data'] as Map<String, dynamic>?,
        isRead: map['is_read'] as bool? ?? false,
        createdAt: map['created_at'] as String? ?? '',
      );
}

class Coach {
  final String id;
  final String fullName;
  final String username;
  final String? avatarUrl;
  final String sportType;
  final double rating;
  final double pricePerSession;
  final String? bio;
  final int experience;
  final double? latitude;
  final double? longitude;

  const Coach({
    required this.id,
    required this.fullName,
    required this.username,
    this.avatarUrl,
    required this.sportType,
    this.rating = 0,
    this.pricePerSession = 100,
    this.bio,
    this.experience = 0,
    this.latitude,
    this.longitude,
  });

  factory Coach.fromMap(Map<String, dynamic> map) => Coach(
        id: map['id'] as String,
        fullName: map['full_name'] as String? ?? '',
        username: map['username'] as String? ?? '',
        avatarUrl: map['avatar_url'] as String?,
        sportType: map['sport_type'] as String? ?? '',
        rating: (map['rating'] as num?)?.toDouble() ?? 0,
        pricePerSession: (map['price_per_session'] as num?)?.toDouble() ?? 100,
        bio: map['bio'] as String?,
        experience: map['experience'] as int? ?? 0,
        latitude: (map['latitude'] as num?)?.toDouble(),
        longitude: (map['longitude'] as num?)?.toDouble(),
      );
}

class Moment {
  final String id;
  final String userId;
  final String imageUrl;
  final String? caption;
  final int likesCount;
  final String createdAt;

  const Moment({
    required this.id,
    required this.userId,
    required this.imageUrl,
    this.caption,
    this.likesCount = 0,
    this.createdAt = '',
  });

  factory Moment.fromMap(Map<String, dynamic> map) => Moment(
        id: map['id'] as String,
        userId: map['user_id'] as String? ?? '',
        imageUrl: map['image_url'] as String? ?? '',
        caption: map['caption'] as String?,
        likesCount: map['likes_count'] as int? ?? 0,
        createdAt: map['created_at'] as String? ?? '',
      );
}

class Review {
  final String id;
  final String userId;
  final String courtId;
  final String? bookingId;
  final int rating;
  final String? comment;
  final String createdAt;

  const Review({
    required this.id,
    required this.userId,
    required this.courtId,
    this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt = '',
  });

  factory Review.fromMap(Map<String, dynamic> map) => Review(
        id: map['id'] as String,
        userId: map['user_id'] as String? ?? '',
        courtId: map['court_id'] as String? ?? '',
        bookingId: map['booking_id'] as String?,
        rating: map['rating'] as int? ?? 5,
        comment: map['comment'] as String?,
        createdAt: map['created_at'] as String? ?? '',
      );
}

// ─── Invitations ───

enum InvitationStatus { pending, accepted, declined }

class Invitation {
  final String id;
  final String senderId;
  final String receiverId;
  final String? matchId;
  final String courtName;
  final String date;
  final String timeSlot;
  final InvitationStatus status;
  final String? message;
  final String createdAt;

  const Invitation({
    required this.id,
    required this.senderId,
    required this.receiverId,
    this.matchId,
    required this.courtName,
    required this.date,
    required this.timeSlot,
    this.status = InvitationStatus.pending,
    this.message,
    this.createdAt = '',
  });

  factory Invitation.fromMap(Map<String, dynamic> map) => Invitation(
        id: map['id'] as String,
        senderId: map['sender_id'] as String? ?? '',
        receiverId: map['receiver_id'] as String? ?? '',
        matchId: map['match_id'] as String?,
        courtName: map['court_name'] as String? ?? '',
        date: map['date'] as String? ?? '',
        timeSlot: map['time_slot'] as String? ?? '',
        status: InvitationStatus.values.firstWhere(
            (e) => e.name == map['status'],
            orElse: () => InvitationStatus.pending),
        message: map['message'] as String?,
        createdAt: map['created_at'] as String? ?? '',
      );
}