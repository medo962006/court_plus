import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../routes.dart';
import '../../../theme/app_theme.dart';
import 'activity_state_provider.dart';
import 'add_review_bottom_sheet.dart';
import 'thank_you_bottom_sheet.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Booking Card — reusable court card for both Current Bookings & Booking History
// ═══════════════════════════════════════════════════════════════════════════════

class BookingCard extends ConsumerStatefulWidget {
  final BookingItem booking;

  const BookingCard({
    super.key,
    required this.booking,
  });

  @override
  ConsumerState<BookingCard> createState() => _BookingCardState();
}

class _BookingCardState extends ConsumerState<BookingCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Update countdown every second for before/during match cards
    if (widget.booking.status != BookingStatus.afterMatch) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Get the live booking from provider state, falling back to widget param.
  BookingItem get _booking {
    final bookings = ref.watch(activityStateProvider);
    return bookings.firstWhere(
      (b) => b.id == widget.booking.id,
      orElse: () => widget.booking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = _booking; // live state from provider
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top Header: Court type + Status tag ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                Text(
                  b.courtType,
                  style: const TextStyle(
                    color: AppColors.lightText,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                _StatusTag(booking: b),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Thumbnail Section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    b.thumbnailAsset,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 80,
                      height: 80,
                      color: AppColors.lightField,
                      child: const Icon(Icons.sports_tennis,
                          color: AppColors.lightMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Right Info Stack
                Expanded(
                  child: SizedBox(
                    height: 80,
                    child: Stack(
                      children: [
                        // Bottom-left: venue + court name
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.venueName,
                                style: const TextStyle(
                                  color: Color(0xFF6B7280), // muted gray
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                b.courtTitle,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937), // dark charcoal
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Top-right: rating
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  size: 14, color: const Color(0xFFFFB800)),
                              const SizedBox(width: 2),
                              Text(
                                '${b.rating}',
                                style: const TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Participant Roster Section ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                // FRIENDS label + stacked avatars
                const Text(
                  'FRIENDS',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 26,
                  width: (b.friendAvatars.length * 16.0) + 10,
                  child: Stack(
                    children: List.generate(b.friendAvatars.length, (i) {
                      return Positioned(
                        left: i * 14.0,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.white, width: 1.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(13),
                            child: Image.asset(
                              b.friendAvatars[i],
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Container(
                                color: AppColors.lightField,
                                child: const Icon(Icons.person,
                                    size: 14,
                                    color: AppColors.lightMuted),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(width: 16),

                // COACH label + single avatar
                if (b.coachName != null) ...[
                  const Text(
                    'COACH',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Image.asset(
                        b.coachAvatar ?? 'assets/images/player.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(
                          color: AppColors.lightField,
                          child: const Icon(Icons.person,
                              size: 14, color: AppColors.lightMuted),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    b.coachName!,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Bottom CTA Button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: _ActionButton(booking: b),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Status Tag — countdown (before/during) or relative time (after)
// ═══════════════════════════════════════════════════════════════════════════════

class _StatusTag extends StatelessWidget {
  final BookingItem booking;
  const _StatusTag({required this.booking});

  @override
  Widget build(BuildContext context) {
    final b = booking;
    if (b.status == BookingStatus.afterMatch) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🕒', style: TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              b.relativeTime,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Before or During — red countdown
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            b.countdownString,
            style: const TextStyle(
              color: Color(0xFFEF4444), // alert red
              fontSize: 11,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Action Button — context-aware CTA
// ═══════════════════════════════════════════════════════════════════════════════

class _ActionButton extends ConsumerWidget {
  final BookingItem booking;

  const _ActionButton({
    required this.booking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = booking;

    String label;
    VoidCallback? onPressed;

    switch (b.status) {
      case BookingStatus.beforeMatch:
        label = 'Enter Court';
        onPressed = () {
          Navigator.of(context).pushNamed(Routes.courtDetails,
            arguments: {'id': b.id, 'name': b.courtTitle},
          );
        };
        break;
      case BookingStatus.duringMatch:
        label = 'Capture a Court+ Moment';
        onPressed = () {
          Navigator.of(context).pushNamed(Routes.moments);
        };
        break;
      case BookingStatus.afterMatch:
        if (b.hasReview) {
          label = 'Reviewed';
          onPressed = null;
        } else {
          label = 'Add Review';
          onPressed = () => _showReviewSheet(context, ref, b);
        }
        break;
    }

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed != null
              ? const Color(0xFFC4FF00) // neon green
              : const Color(0xFFE5E7EB),
          foregroundColor: onPressed != null
              ? const Color(0xFF1F2937)
              : const Color(0xFF9CA3AF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(label),
      ),
    );
  }

  void _showReviewSheet(BuildContext context, WidgetRef ref, BookingItem b) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddReviewBottomSheet(
        booking: b,
        onSubmitted: (stars) {
          // Mark reviewed
          ref.read(activityStateProvider.notifier).markReviewed(b.id, stars);
          // Show thank you sheet
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              showThankYouSheet(context);
            }
          });
        },
      ),
    );
  }
}