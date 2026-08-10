import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/supabase_service.dart';
import '../../../services/models.dart' as backend;
import '../../providers/supabase_provider.dart';

/// Match lifecycle states for each booking.
enum BookingStatus { beforeMatch, duringMatch, afterMatch }

/// A single booking / match item displayed in the activity tab.
class BookingItem {
  final String id;
  final String courtType;
  final String venueName;
  final String courtTitle;
  final String thumbnailAsset;
  final double rating;
  final BookingStatus status;
  final DateTime matchStartTime;
  final List<String> friendAvatars;
  final String? coachName;
  final String? coachAvatar;
  bool hasReview;
  int reviewStars;

  BookingItem({
    required this.id,
    required this.courtType,
    required this.venueName,
    required this.courtTitle,
    required this.thumbnailAsset,
    required this.rating,
    required this.status,
    required this.matchStartTime,
    required this.friendAvatars,
    this.coachName,
    this.coachAvatar,
    this.hasReview = false,
    this.reviewStars = 0,
  });

  /// Construct a BookingItem from a backend [backend.Booking] model.
  factory BookingItem.fromBackendBooking(backend.Booking booking) {
    final now = DateTime.now();

    // Parse the booking date + time slot to determine matchStartTime
    DateTime matchStartTime;
    try {
      final dateParts = booking.date.split('-');
      final timeParts = booking.timeSlot.split(':');
      if (dateParts.length == 3 && timeParts.length == 2) {
        matchStartTime = DateTime(
          int.parse(dateParts[0]),
          int.parse(dateParts[1]),
          int.parse(dateParts[2]),
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
      } else {
        matchStartTime = now;
      }
    } catch (_) {
      matchStartTime = now;
    }

    // Compute activity display status from booking status + date
    final BookingStatus displayStatus;
    switch (booking.status) {
      case backend.BookingStatus.completed:
        displayStatus = BookingStatus.afterMatch;
        break;
      case backend.BookingStatus.cancelled:
        displayStatus = BookingStatus.afterMatch;
        break;
      case backend.BookingStatus.confirmed:
        if (matchStartTime.isAfter(now)) {
          displayStatus = BookingStatus.beforeMatch;
        } else if (matchStartTime.isBefore(now) &&
            matchStartTime.add(const Duration(hours: 3)).isAfter(now)) {
          displayStatus = BookingStatus.duringMatch;
        } else {
          displayStatus = BookingStatus.afterMatch;
        }
        break;
      case backend.BookingStatus.pending:
        displayStatus = BookingStatus.beforeMatch;
        break;
    }

    return BookingItem(
      id: booking.id,
      courtType: '🎾 Booked Court',
      venueName: booking.courtName,
      courtTitle: booking.courtName,
      thumbnailAsset: 'assets/images/court1.jpg',
      rating: 0,
      status: displayStatus,
      matchStartTime: matchStartTime,
      friendAvatars: const [],
      hasReview: false,
      reviewStars: 0,
    );
  }

  /// Relative time label shown in "Booking History".
  String get relativeTime {
    final diff = DateTime.now().difference(matchStartTime);
    if (diff.inDays > 0) return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    if (diff.inHours > 0) return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    return 'Just now';
  }

  /// Live countdown string for before/during matches.
  String get countdownString {
    final diff = matchStartTime.difference(DateTime.now());
    if (diff.isNegative) {
      final elapsed = DateTime.now().difference(matchStartTime);
      final h = elapsed.inHours.remainder(24).clamp(0, 99);
      final m = elapsed.inMinutes.remainder(60).clamp(0, 59);
      final s = elapsed.inSeconds.remainder(60).clamp(0, 59);
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    final h = diff.inHours.remainder(24).clamp(0, 99);
    final m = diff.inMinutes.remainder(60).clamp(0, 59);
    final s = diff.inSeconds.remainder(60).clamp(0, 59);
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

/// State notifier managing the list of bookings from Supabase.
class ActivityStateNotifier extends StateNotifier<List<BookingItem>> {
  final SupabaseService _supabase;

  ActivityStateNotifier(this._supabase) : super(const []) {
    _load();
  }

  /// Load bookings from Supabase and convert to BookingItems.
  Future<void> _load() async {
    final result = await _supabase.getUserBookings();
    result.fold(
      (bookings) {
        state = bookings
            .map((b) => BookingItem.fromBackendBooking(b))
            .toList();
      },
      (_) {
        state = const [];
      },
    );
  }

  /// Refresh bookings from Supabase.
  Future<void> refresh() => _load();

  /// Mark a booking as reviewed and record star count.
  void markReviewed(String bookingId, int stars) {
    state = state.map((b) {
      if (b.id == bookingId) {
        return BookingItem(
          id: b.id,
          courtType: b.courtType,
          venueName: b.venueName,
          courtTitle: b.courtTitle,
          thumbnailAsset: b.thumbnailAsset,
          rating: b.rating,
          status: b.status,
          matchStartTime: b.matchStartTime,
          friendAvatars: b.friendAvatars,
          coachName: b.coachName,
          coachAvatar: b.coachAvatar,
          hasReview: true,
          reviewStars: stars,
        );
      }
      return b;
    }).toList();
  }
}

final activityStateProvider =
    StateNotifierProvider<ActivityStateNotifier, List<BookingItem>>(
  (ref) => ActivityStateNotifier(ref.read(supabaseServiceProvider)),
);