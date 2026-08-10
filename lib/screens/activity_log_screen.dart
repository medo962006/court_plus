import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/booking_provider.dart';
import '../services/models.dart';
import '../routes.dart';

class ActivityLogScreen extends ConsumerStatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  ConsumerState<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends ConsumerState<ActivityLogScreen> {
  @override
  Widget build(BuildContext context) {
    // Automatically fetched by userBookingsProvider
    final bookingsAsync = ref.watch(userBookingsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        title: const Text('Activity',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: bookingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(Ph.warning_circle, size: 48, color: AppColors.lightMuted),
                SizedBox(height: 12),
                Text('Could not load bookings', style: TextStyle(color: AppColors.lightMuted, fontSize: 16)),
              ],
            ),
          ),
        ),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Iconify(Ph.calendar_blank, size: 48, color: AppColors.lightMuted),
                  SizedBox(height: 12),
                  Text('No bookings yet', style: TextStyle(color: AppColors.lightMuted, fontSize: 16)),
                  SizedBox(height: 4),
                  Text('Book a court to see it here', style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final b = bookings[i];
              final isConfirmed = b.status == BookingStatus.confirmed;
              return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(Routes.bookingTicket, arguments: b.id),
                child: Container(
                  padding: EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(child: Iconify(
                            isConfirmed ? Ph.tennis_ball : Ph.hourglass,
                            size: 22, color: AppColors.neonGreen)),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.courtName,
                                style: TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w600)),
                            SizedBox(height: 2),
                            Text('${b.date} · ${b.timeSlot} · \$${b.totalAmount.toStringAsFixed(2)}',
                                style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                            SizedBox(height: 4),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: isConfirmed ? Color(0xFFE8F5E9) : Color(0xFFFFF3E0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isConfirmed ? 'Confirmed' : 'Pending',
                                style: TextStyle(
                                  color: isConfirmed ? Color(0xFF2E7D32) : Color(0xFFE65100),
                                  fontSize: 11, fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Iconify(Ph.caret_right, size: 16, color: AppColors.lightMuted),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}