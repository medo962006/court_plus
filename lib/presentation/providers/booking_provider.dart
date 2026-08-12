import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/models.dart';
import '../../services/supabase_service.dart';
import '../../services/event_tracker.dart';
import 'supabase_provider.dart';

// ─── State ───

final class BookingState {
  final Court? court;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final double duration;
  final List<String> addOns;
  final double totalAmount;
  final String? paymentMethod;
  final bool isLoading;
  final String? error;
  final List<Booking> userBookings;
  final String? bookingId;

  const BookingState({
    this.court,
    this.selectedDate,
    this.selectedTimeSlot,
    this.duration = 1.0,
    this.addOns = const [],
    this.totalAmount = 0,
    this.paymentMethod,
    this.isLoading = false,
    this.error,
    this.userBookings = const [],
    this.bookingId,
  });

  BookingState copyWith({
    Court? court,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    double? duration,
    List<String>? addOns,
    double? totalAmount,
    String? paymentMethod,
    bool? isLoading,
    String? error,
    List<Booking>? userBookings,
    String? bookingId,
    bool clearError = false,
  }) => BookingState(
    court: court ?? this.court,
    selectedDate: selectedDate ?? this.selectedDate,
    selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
    duration: duration ?? this.duration,
    addOns: addOns ?? this.addOns,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    userBookings: userBookings ?? this.userBookings,
    bookingId: bookingId ?? this.bookingId,
  );
}

// ─── Providers ───

final bookingStateProvider = StateNotifierProvider<BookingNotifier, BookingState>(
  (ref) => BookingNotifier(ref.read(supabaseServiceProvider)),
);

final userBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getUserBookings();
  return result.fold(
    (bookings) => bookings,
    (e) => throw e,
  );
});

final bookingLoadingProvider = Provider<bool>((ref) {
  return ref.watch(bookingStateProvider).isLoading;
});

// ─── Notifier ───

final class BookingNotifier extends StateNotifier<BookingState> {
  final SupabaseService _supabase;

  BookingNotifier(this._supabase) : super(const BookingState());

  void setCourt(Court court) {
    state = state.copyWith(court: court);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setTimeSlot(String slot) {
    state = state.copyWith(selectedTimeSlot: slot);
  }

  void setDuration(double duration) {
    state = state.copyWith(duration: duration);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setAddOns(Map<String, int> addOnsMap) {
    final addOnsList = addOnsMap.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key} x${e.value}')
        .toList();
    state = state.copyWith(addOns: addOnsList);
  }

  void setTotalAmount(double amount) {
    state = state.copyWith(totalAmount: amount);
  }

  Future<String?> createBooking() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final court = state.court;
      final date = state.selectedDate;
      final timeSlot = state.selectedTimeSlot;
      if (court == null || date == null || timeSlot == null) {
        state = state.copyWith(isLoading: false, error: 'Missing booking details');
        return 'Missing booking details';
      }

      final result = await _supabase.lockBookingSlot(
        courtId: court.id,
        date: date.toIso8601String().split('T')[0],
        timeSlot: timeSlot,
        duration: state.duration,
      );
      return result.fold(
        (data) {
          final bookingId = data['booking_id'] as String?;
          final amount = (data['total_amount'] as num?)?.toDouble() ?? 0;
          state = state.copyWith(
            isLoading: false,
            totalAmount: amount,
            bookingId: bookingId,
          );
          EventTracker.instance.track(
            'booking_created',
            props: {
              'court': court.name,
              'courtId': court.id,
              'date': date.toIso8601String().split('T')[0],
              'timeSlot': timeSlot,
              'amount': amount,
            },
          );
          return null; // ← null = success
        },
        (e) {
          state = state.copyWith(isLoading: false, error: e.message);
          return e.message;
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return e.toString();
    }
  }

  Future<void> loadUserBookings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _supabase.getUserBookings();
    result.fold(
      (bookings) {
        state = state.copyWith(isLoading: false, userBookings: bookings);
      },
      (e) {
        state = state.copyWith(isLoading: false, error: e.message);
      },
    );
  }

  void reset() {
    state = const BookingState();
  }

  void clearError() => state = state.copyWith(clearError: true);
}