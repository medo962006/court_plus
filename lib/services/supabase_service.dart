import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import '../core/result.dart';
import '../core/logger.dart';
import '../core/config.dart';
import 'models.dart';

/// Singleton service wrapping Supabase client.
class SupabaseService {
  @visibleForTesting
  SupabaseService.test() : _initialized = true;

  SupabaseService._();
  static final SupabaseService _instance = SupabaseService._();
  factory SupabaseService() => _instance;

  late final GoTrueClient _auth;
  late final SupabaseClient _client;
  bool _initialized = false;

  GoTrueClient get auth => _auth;
  SupabaseClient get client => _client;
  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentSession != null;

  Future<Result<void>> init() async {
    if (_initialized) return Result.success(null);
    await AppConfig.init();
    try {
      await Supabase.initialize(
        url: AppConfig.supabaseUrl,
        publishableKey: AppConfig.supabaseAnonKey,
      );
      _client = Supabase.instance.client;
      _auth = _client.auth;
      _initialized = true;
      AppLogger.info('Supabase initialized');
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('Supabase init failed', error: e, stack: s);
      return Result.failure(
        ServerException('Failed to connect to server: $e'),
      );
    }
  }

  // ─── Auth ───

  Future<Result<void>> sendOtp(String email) async {
      try {
        await _auth.signInWithOtp(
          email: email,
          emailRedirectTo: 'com.courtplus.court_plus://callback',
        );
        AppLogger.info('OTP sent to $email');
        return Result.success(null);
      } catch (e, s) {
        AppLogger.error('sendOtp failed', error: e, stack: s);
        final msg = e.toString();
        if (msg.contains('over_email_send_rate_limit') || msg.contains('429')) {
          return Result.failure(
            AuthException('Too many requests. Please wait 1 minute before trying again.'),
          );
        }
        return Result.failure(
          AuthException('Failed to send code: $e'),
        );
      }
    }

  /// Send a phone-number OTP via SMS (Supabase Auth → Twilio/MessageBird).
  Future<Result<void>> sendPhoneOtp(String phone) async {
    try {
      await _auth.signInWithOtp(phone: phone);
      AppLogger.info('SMS OTP sent to $phone');
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('sendPhoneOtp failed', error: e, stack: s);
      return Result.failure(
        AuthException('Failed to send SMS code: $e'),
      );
    }
  }

  /// Verify a phone OTP and return the authenticated profile.
  Future<Result<UserProfile?>> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    try {
      final response = await _auth.verifyOTP(
        phone: phone,
        token: code,
        type: OtpType.sms,
      );
      final user = response.user;
      if (user == null) {
        return Result.failure(
          AuthException('Verification failed — no user returned'),
        );
      }
      AppLogger.info('User authenticated via SMS OTP: ${user.id}');
      return Result.success(UserProfile(
        id: user.id,
        fullName: user.userMetadata?['full_name'] as String? ?? '',
        username: user.phone ?? 'user_${user.id.substring(0, 8)}',
        phone: user.phone,
      ));
    } catch (e, s) {
      AppLogger.error('verifyPhoneOtp failed', error: e, stack: s);
      return Result.failure(
        AuthException('Invalid code: $e'),
      );
    }
  }

  Future<Result<UserProfile?>> verifyOtp({
    required String email,
    required String code,
    String? fullName,
    String? username,
  }) async {
    try {
      final response = await _auth.verifyOTP(
              email: email,
              token: code,
              type: OtpType.email,
            );
      final user = response.user;
      if (user == null) {
        return Result.failure(
          AuthException('Verification failed — no user returned'),
        );
      }
      if (fullName != null && username != null) {
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': fullName,
          'username': username,
          'email': email,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
      AppLogger.info('User authenticated: ${user.id}');
      return Result.success(
        UserProfile(id: user.id, fullName: fullName ?? '', username: username ?? ''),
      );
    } catch (e, s) {
      AppLogger.error('verifyOtp failed', error: e, stack: s);
      return Result.failure(
        AuthException('Invalid code: $e'),
      );
    }
  }

  Future<Result<void>> signOut() async {
      try {
        await _auth.signOut();
        AppLogger.info('User signed out');
        return Result.success(null);
      } catch (e, s) {
        AppLogger.error('signOut failed', error: e, stack: s);
        return Result.failure(
          AuthException('Failed to sign out: $e'),
        );
      }
    }

    /// Sign in with email + password.
    Future<Result<UserProfile?>> signInWithPassword({
      required String email,
      required String password,
    }) async {
      try {
        final response = await _auth.signInWithPassword(
          email: email,
          password: password,
        );
        final user = response.user;
        if (user == null) {
          return Result.failure(
            AuthException('Sign-in failed — no user returned'),
          );
        }
        final profile = await _upsertOAuthProfile(user);
        AppLogger.info('User signed in with password: ${user.id}');
        return Result.success(profile);
      } catch (e, s) {
        AppLogger.error('signInWithPassword failed', error: e, stack: s);
        final msg = e.toString();
        if (msg.contains('Invalid login credentials')) {
          return Result.failure(
            AuthException('Invalid email or password. Please try again.'),
          );
        }
        return Result.failure(
          AuthException('Sign-in failed: $e'),
        );
      }
    }

    /// Sign in anonymously (guest mode).
    Future<Result<UserProfile?>> signInAnonymously() async {
      try {
        final response = await _auth.signInAnonymously();
        final user = response.user;
        if (user == null) {
          return Result.failure(
            AuthException('Anonymous sign-in failed — no user returned'),
          );
        }
        // Create a minimal profile for anonymous users
        await _client.from('profiles').upsert({
          'id': user.id,
          'full_name': 'Guest',
          'username': 'guest_${user.id.substring(0, 8)}',
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'id');
        AppLogger.info('Anonymous user signed in: ${user.id}');
        return Result.success(UserProfile(
          id: user.id,
          fullName: 'Guest',
          username: 'guest_${user.id.substring(0, 8)}',
        ));
      } catch (e, s) {
        AppLogger.error('signInAnonymously failed', error: e, stack: s);
        return Result.failure(
          AuthException('Guest sign-in failed: $e'),
        );
      }
    }

    /// Send a password reset email.
        Future<Result<void>> sendPasswordResetEmail(String email) async {
          try {
            await _auth.resetPasswordForEmail(
              email,
              redirectTo: 'com.courtplus.court_plus://reset-password',
            );
            AppLogger.info('Password reset email sent to $email');
            return Result.success(null);
          } catch (e, s) {
            AppLogger.error('sendPasswordResetEmail failed', error: e, stack: s);
            return Result.failure(
              AuthException('Failed to send password reset email: $e'),
            );
          }
        }

        /// Register a new user with email + password + profile metadata.
                /// Creates the auth user (sends OTP if email confirmation is enabled)
                /// and sets raw_user_meta_data for the on_auth_user_created trigger.
                /// Profile row is auto-created by the DB trigger — no manual upsert needed.
                Future<Result<UserProfile?>> signUp({
                  required String email,
                  required String password,
                  required String fullName,
                  required String username,
                  String? phone,
                  String? dateOfBirth,
                  String? gender,
                }) async {
                  try {
                    final response = await _auth.signUp(
                      email: email,
                      password: password,
                      data: {
                                              'full_name': fullName,
                                              'username': username,
                                              'phone': ?phone,
                                              'date_of_birth': ?dateOfBirth,
                                              'gender': ?gender,
                                            },
                    );
                    final user = response.user;
                    if (user == null) {
                      // Email confirmation required — OTP sent, pending verification
                      return Result.success(null);
                    }
                    // User created immediately — profile auto-created by trigger
                    AppLogger.info('User signed up: ${user.id}');
                    return Result.success(UserProfile(
                      id: user.id,
                      fullName: fullName,
                      username: username,
                      email: email,
                      phone: phone,
                      dateOfBirth: dateOfBirth,
                      gender: gender,
                    ));
                  } catch (e, s) {
            AppLogger.error('signUp failed', error: e, stack: s);
            final msg = e.toString();
            if (msg.contains('already registered') || msg.contains('already exists') || msg.contains('duplicate')) {
              return Result.failure(
                AuthException('An account with this email already exists. Please sign in instead.'),
              );
            }
            return Result.failure(
              AuthException('Sign-up failed: $e'),
            );
          }
        }

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;

  // ─── OAuth (Google / Apple) ───

    /// Wait for the next `signedIn` event on the auth state stream.
    /// Returns the authenticated User, or null if the timeout fires first.
    Future<User?> _waitForOAuthSession({
      Duration timeout = const Duration(seconds: 60),
    }) async {
      // First check if session already exists (fast path)
      if (_auth.currentSession?.user != null) {
        return _auth.currentSession!.user;
      }

      // Otherwise listen for the next signedIn event
      final completer = Completer<User?>();
      StreamSubscription<AuthState>? sub;

      final timer = Timer(timeout, () {
        sub?.cancel();
        if (!completer.isCompleted) completer.complete(null);
      });

      sub = _auth.onAuthStateChange.listen((state) {
        if (state.event == AuthChangeEvent.signedIn && state.session?.user != null) {
          timer.cancel();
          sub?.cancel();
          if (!completer.isCompleted) completer.complete(state.session!.user);
        }
      });

      return completer.future;
    }

    /// Shared profile upsert logic for OAuth sign-ins.
    Future<UserProfile> _upsertOAuthProfile(User user) async {
      final fullName = user.userMetadata?['full_name'] as String? ?? '';
      final username = user.email?.split('@').first ?? 'user_${user.id.substring(0, 8)}';
      final avatarUrl = user.userMetadata?['avatar_url'] as String?;

      await _client.from('profiles').upsert({
        'id': user.id,
        'full_name': fullName,
        'username': username,
        'email': user.email,
        'avatar_url': avatarUrl,
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'id');

      return UserProfile(
        id: user.id,
        fullName: fullName,
        username: username,
        email: user.email,
        avatarUrl: avatarUrl,
      );
    }

    /// Sign in with Google using OAuth + profile auto-creation.
        Future<Result<UserProfile?>> signInWithGoogle() async {
          try {
            await _auth.signInWithOAuth(
              OAuthProvider.google,
              redirectTo: kIsWeb ? null : 'com.courtplus.court_plus://callback',
            );

            final user = await _waitForOAuthSession(timeout: const Duration(seconds: 30));
            if (user == null) {
              return Result.failure(AuthException(
                'Google sign-in timed out. Make sure Google is enabled in your Supabase dashboard '
                '(Authentication → Providers → Google).',
              ));
            }

            final profile = await _upsertOAuthProfile(user);
            AppLogger.info('Google sign-in successful: ${user.id}');
            return Result.success(profile);
          } catch (e, s) {
            AppLogger.error('Google sign-in failed', error: e, stack: s);
            final msg = e.toString();
            if (msg.contains('Unsupported provider') || msg.contains('provider is not enabled')) {
              return Result.failure(AuthException(
                'Google sign-in is not configured. Please enable Google in your '
                'Supabase dashboard (Authentication → Providers → Google).',
              ));
            }
            return Result.failure(AuthException('Google sign-in failed: $e'));
          }
        }

        /// Sign in with Apple using OAuth + profile auto-creation.
        Future<Result<UserProfile?>> signInWithApple() async {
          try {
            await _auth.signInWithOAuth(
              OAuthProvider.apple,
              redirectTo: kIsWeb ? null : 'com.courtplus.court_plus://callback',
            );

            final user = await _waitForOAuthSession(timeout: const Duration(seconds: 30));
            if (user == null) {
              return Result.failure(AuthException(
                'Apple sign-in timed out. Make sure Apple is enabled in your Supabase dashboard '
                '(Authentication → Providers → Apple).',
              ));
            }

            final profile = await _upsertOAuthProfile(user);
            AppLogger.info('Apple sign-in successful: ${user.id}');
            return Result.success(profile);
          } catch (e, s) {
            AppLogger.error('Apple sign-in failed', error: e, stack: s);
            final msg = e.toString();
            if (msg.contains('Unsupported provider') || msg.contains('provider is not enabled')) {
              return Result.failure(AuthException(
                'Apple sign-in is not configured. Please enable Apple in your '
                'Supabase dashboard (Authentication → Providers → Apple).',
              ));
            }
            return Result.failure(AuthException('Apple sign-in failed: $e'));
          }
        }

  // ─── Profile ───

  Future<Result<UserProfile?>> getProfile(String userId) async {
    try {
      final res = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      final data = res;
      if (data == null) return Result.success(null);
      return Result.success(UserProfile.fromMap(data));
    } catch (e, s) {
      AppLogger.error('getProfile failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load profile: $e'));
    }
  }

  Future<Result<UserProfile>> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      final data = await _client
          .from('profiles')
          .update(updates)
          .eq('id', userId)
          .select()
          .single();
      return Result.success(UserProfile.fromMap(data));
    } catch (e, s) {
      AppLogger.error('updateProfile failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to update profile: $e'));
    }
  }

  // ─── Courts ───

    Future<Result<List<Court>>> getCourts({String? sportType}) async {
      try {
        var query = _client.from('courts').select();
        if (sportType != null && sportType != 'all') {
          query = query.eq('sport_type', sportType);
        }
        final List data = await query;
        final list = data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();
        return Result.success(list);
      } catch (e, s) {
        AppLogger.error('getCourts failed', error: e, stack: s);
        return Result.failure(ServerException('Failed to load courts: $e'));
      }
    }

    /// Search courts with full-text + geo-radius filter via the `search_courts` RPC.
    Future<Result<List<Court>>> searchCourts({
      String? sportType,
      double? minPrice,
      double? maxPrice,
      double? minRating,
      double? lat,
      double? lng,
      double? radiusKm,
      String? searchTerm,
    }) async {
      try {
        final params = <String, dynamic>{
                  'p_sport_type': sportType != null && sportType != 'all' ? sportType : null,
                  'p_min_price': minPrice,
                  'p_max_price': maxPrice,
                  'p_min_rating': minRating,
                  'p_lat': lat,
                  'p_lng': lng,
                  'p_radius_km': radiusKm,
                  'p_search_term': (searchTerm != null && searchTerm.isNotEmpty) ? searchTerm : null,
                }..removeWhere((_, v) => v == null);
        final List data = await _client.rpc('search_courts', params: params);
        final list = data.map((e) => Court.fromMap(e as Map<String, dynamic>)).toList();
        return Result.success(list);
      } catch (e, s) {
        AppLogger.error('searchCourts failed', error: e, stack: s);
        return Result.failure(ServerException('Failed to search courts: $e'));
      }
    }

    /// Get available time slots for a court on a given date.
    Future<Result<List<Map<String, dynamic>>>> getAvailableSlots({
      required String courtId,
      required String date,
    }) async {
      try {
        final List data = await _client.rpc('get_available_slots', params: {
          'p_court_id': courtId,
          'p_date': date,
        });
        return Result.success(data.cast<Map<String, dynamic>>());
      } catch (e, s) {
        AppLogger.error('getAvailableSlots failed', error: e, stack: s);
        return Result.failure(ServerException('Failed to load slots: $e'));
      }
    }

  // ─── Bookings (RPC-based double-booking lock) ───

    /// Lock a time slot and create a pending booking atomically.
    /// Uses the `lock_booking_slot` RPC with SELECT FOR UPDATE.
    Future<Result<Map<String, dynamic>>> lockBookingSlot({
      required String courtId,
      required String date,
      required String timeSlot,
      required double duration,
    }) async {
      try {
        final userId = currentUser?.id;
        if (userId == null) {
          return Result.failure(AuthException('User not authenticated'));
        }
        final result = await _client.rpc('lock_booking_slot', params: {
          'p_court_id': courtId,
          'p_date': date,
          'p_start_time': timeSlot,
          'p_duration': duration,
          'p_user_id': userId,
        });
        final data = result as Map<String, dynamic>;
        if (data['success'] == true) {
          return Result.success(data);
        }
        return Result.failure(
          ServerException(data['error'] as String? ?? 'Slot unavailable'),
        );
      } catch (e, s) {
        AppLogger.error('lockBookingSlot failed', error: e, stack: s);
        return Result.failure(ServerException('Failed to lock slot: $e'));
      }
    }

    // ─── Payments ───

  Future<Result<void>> processPayment({
    required double amount,
    required String method,
    String? bookingId,
  }) async {
    try {
      AppLogger.info('Processing payment: $amount via $method');
      await _client.from('payments').insert({
        'booking_id': bookingId,
        'amount': amount,
        'method': method,
        'status': 'completed',
        'created_at': DateTime.now().toIso8601String(),
      });
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('processPayment failed', error: e, stack: s);
      return Result.failure(ServerException('Payment failed: $e'));
    }
  }

  // ─── User Bookings ───

  Future<Result<List<Booking>>> getUserBookings() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        return Result.failure(AuthException('User not authenticated'));
      }
      final List data = await _client
          .from('bookings')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final list = data
          .map((e) => Booking.fromMap(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e, s) {
      AppLogger.error('getUserBookings failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load bookings: $e'));
    }
  }

  // ─── User Matches ───

  Future<Result<List<Match>>> getUserMatches() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        return Result.failure(AuthException('User not authenticated'));
      }
      final List data = await _client
          .from('matches')
          .select()
          .eq('creator_id', userId)
          .order('date', ascending: false);
      final list = data
          .map((e) => Match.fromMap(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e, s) {
      AppLogger.error('getUserMatches failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load matches: $e'));
    }
  }

  // ─── Notifications ───

  Future<Result<List<NotificationItem>>> getUserNotifications() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        return Result.failure(AuthException('User not authenticated'));
      }
      final List data = await _client
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      final list = data
          .map((e) => NotificationItem.fromMap(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e, s) {
      AppLogger.error('getUserNotifications failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load notifications: $e'));
    }
  }

  // ─── Moments ───

    Future<Result<Moment>> createMoment(Map<String, dynamic> data) async {
      try {
        data['created_at'] = DateTime.now().toIso8601String();
        data['user_id'] = currentUser?.id;
        final result = await _client
            .from('moments')
            .insert(data)
            .select()
            .single();
        return Result.success(Moment.fromMap(result));
      } catch (e, s) {
        AppLogger.error('createMoment failed', error: e, stack: s);
        return Result.failure(ServerException('Failed to create moment: $e'));
      }
    }

    Future<Result<List<Moment>>> getMoments() async {
    try {
      final List data = await _client
          .from('moments')
          .select()
          .order('created_at', ascending: false);
      final list = data
          .map((e) => Moment.fromMap(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e, s) {
      AppLogger.error('getMoments failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load moments: $e'));
    }
  }

  // ─── Invitations ───

  Future<Result<List<Invitation>>> getInvitations() async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        return Result.failure(AuthException('User not authenticated'));
      }
      final List data = await _client
          .from(DbTables.invitations)
          .select()
          .eq('receiver_id', userId)
          .order('created_at', ascending: false);
      final list = data
          .map((e) => Invitation.fromMap(e as Map<String, dynamic>))
          .toList();
      return Result.success(list);
    } catch (e, s) {
      AppLogger.error('getInvitations failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to load invitations: $e'));
    }
  }

  Future<Result<void>> respondToInvitation(
      String id, String status) async {
    try {
      await _client.from(DbTables.invitations).update({
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('respondToInvitation failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to respond: $e'));
    }
  }

  Future<Result<void>> sendInvitation(Map<String, dynamic> data) async {
    try {
      data['created_at'] = DateTime.now().toIso8601String();
      await _client.from(DbTables.invitations).insert(data);
      return Result.success(null);
    } catch (e, s) {
      AppLogger.error('sendInvitation failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to send invitation: $e'));
    }
  }

    // ─── Coaches ───

    Future<Result<List<Coach>>> getCoaches({String? sportType}) async {
      try {
        var query = _client.from('coaches').select().eq('is_active', true);
        if (sportType != null && sportType != 'all') {
          query = query.eq('sport_type', sportType);
        }
        final List data = await query.order('rating', ascending: false);
        final list = data.map((e) => Coach.fromMap(e as Map<String, dynamic>)).toList();
        return Result.success(list);
      } catch (e, s) {
        AppLogger.error('getCoaches failed', error: e, stack: s);
        return Result.failure(ServerException('Failed to load coaches: $e'));
      }
    }

      // ─── Reviews ───

      Future<Result<Review>> addReview({


    required String courtId,
    required int rating,
    String? comment,
    String? bookingId,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) {
        return Result.failure(AuthException('User not authenticated'));
      }
      final data = await _client.from('reviews').insert({
        'user_id': userId,
        'court_id': courtId,
        'booking_id': bookingId,
        'rating': rating,
        'comment': comment,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      return Result.success(Review.fromMap(data));
    } catch (e, s) {
      AppLogger.error('addReview failed', error: e, stack: s);
      return Result.failure(ServerException('Failed to submit review: $e'));
          }
        }

          // ─── Social Interactions (Favorites, Follows, Likes, Comments) ───

          Future<Result<void>> addFavorite(String userId, String courtId) async {
            try {
              await _client.from('favorites').insert({
                'user_id': userId,
                'court_id': courtId,
                'created_at': DateTime.now().toIso8601String(),
              });
              return Result.success(null);
            } catch (e, s) {
              AppLogger.error('addFavorite failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to add favorite: $e'));
            }
          }

          Future<Result<void>> removeFavorite(String userId, String courtId) async {
            try {
              await _client.from('favorites').delete().match({'user_id': userId, 'court_id': courtId});
              return Result.success(null);
            } catch (e, s) {
              AppLogger.error('removeFavorite failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to remove favorite: $e'));
            }
          }

          Future<Result<List<String>>> getFavorites(String userId) async {
            try {
              final List data = await _client.from('favorites').select('court_id').eq('user_id', userId);
              final ids = data.map((e) => e['court_id'] as String).toList();
              return Result.success(ids);
            } catch (e, s) {
              AppLogger.error('getFavorites failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to load favorites: $e'));
            }
          }

          Future<Result<bool>> isFavorited(String userId, String courtId) async {
            try {
              final List data = await _client.from('favorites').select('id').match({'user_id': userId, 'court_id': courtId});
              return Result.success(data.isNotEmpty);
            } catch (e, s) {
              AppLogger.error('isFavorited failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to check favorite: $e'));
            }
          }

          Future<Result<void>> followUser(String followerId, String followingId) async {
            try {
              await _client.from('follows').insert({
                'follower_id': followerId,
                'following_id': followingId,
                'created_at': DateTime.now().toIso8601String(),
              });
              return Result.success(null);
            } catch (e, s) {
              AppLogger.error('followUser failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to follow user: $e'));
            }
          }

          Future<Result<void>> unfollowUser(String followerId, String followingId) async {
            try {
              await _client.from('follows').delete().match({'follower_id': followerId, 'following_id': followingId});
              return Result.success(null);
            } catch (e, s) {
              AppLogger.error('unfollowUser failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to unfollow user: $e'));
            }
          }

          Future<Result<List<String>>> getFollowing(String userId) async {
            try {
              final List data = await _client.from('follows').select('following_id').eq('follower_id', userId);
              final ids = data.map((e) => e['following_id'] as String).toList();
              return Result.success(ids);
            } catch (e, s) {
              AppLogger.error('getFollowing failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to load following: $e'));
            }
          }

          Future<Result<void>> likeMoment(String momentId, String userId) async {
            try {
              await _client.from('moment_likes').insert({
                'moment_id': momentId,
                'user_id': userId,
                'created_at': DateTime.now().toIso8601String(),
              });
              return Result.success(null);
            } catch (e, s) {
              AppLogger.error('likeMoment failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to like moment: $e'));
            }
          }

          Future<Result<void>> unlikeMoment(String momentId, String userId) async {
            try {
              await _client.from('moment_likes').delete().match({'moment_id': momentId, 'user_id': userId});
              return Result.success(null);
            } catch (e, s) {
              AppLogger.error('unlikeMoment failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to unlike moment: $e'));
            }
          }

          Future<Result<void>> addMomentComment(String momentId, String userId, String comment) async {
            try {
              await _client.from('moment_comments').insert({
                'moment_id': momentId,
                'user_id': userId,
                'comment': comment,
                'created_at': DateTime.now().toIso8601String(),
              });
              return Result.success(null);
            } catch (e, s) {
              AppLogger.error('addMomentComment failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to add comment: $e'));
            }
          }

          Future<Result<List<Map<String, dynamic>>>> getMomentComments(String momentId) async {
            try {
              final List data = await _client.from('moment_comments').select('id, comment, created_at, user_id').eq('moment_id', momentId).order('created_at', ascending: true);
              return Result.success(data.cast<Map<String, dynamic>>());
            } catch (e, s) {
              AppLogger.error('getMomentComments failed', error: e, stack: s);
              return Result.failure(ServerException('Failed to load comments: $e'));
            }
          }
      }