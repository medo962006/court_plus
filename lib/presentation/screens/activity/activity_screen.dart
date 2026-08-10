import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../../../theme/app_theme.dart';
import '../../../routes.dart';
import '../../../widgets/bottom_nav_bar.dart';
import 'activity_state_provider.dart';
import 'booking_card_widget.dart';

/// Main Activity Screen with "Current Bookings" & "Booking History" tabs.
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 3; // Activity tab active
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(activityStateProvider);

    // Current bookings: beforeMatch + duringMatch
    final currentBookings = bookings
        .where((b) =>
            b.status == BookingStatus.beforeMatch ||
            b.status == BookingStatus.duringMatch)
        .toList();
    // Booking history: afterMatch
    final historyBookings = bookings
        .where((b) => b.status == BookingStatus.afterMatch)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 56,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Iconify(
            Ph.stack_simple,
            size: 22,
            color: AppColors.lightText,
          ),
        ),
        leadingWidth: 48,
        title: const Text(
          'Activity',
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE1E4E8)),
                  ),
                  child: const Icon(
                    Icons.notifications_none,
                    color: AppColors.lightText,
                    size: 22,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: const Color(0xFF1F2937),
                  unselectedLabelColor: const Color(0xFF6B7280),
                  indicatorColor: const Color(0xFF9BEC00),
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  padding: EdgeInsets.zero,
                  tabs: const [
                    Tab(text: 'Current bookings'),
                    Tab(text: 'Booking History'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(currentBookings),
          _buildList(historyBookings, showReviewCards: true),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        index: _navIndex,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushNamed(Routes.courts);
          } else if (i == 1) {
            Navigator.of(context).pushNamed(Routes.explore);
          } else if (i == 2) {
            Navigator.of(context).pushNamed(Routes.home);
          } else if (i == 4) {
            Navigator.of(context).pushNamed(Routes.profile);
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }

  Widget _buildList(List<BookingItem> bookings, {bool showReviewCards = false}) {
    final reviewCards = showReviewCards ? [
      // To Be Reviewed card
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star_border, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                const Text('To Be Reviewed',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1F2937))),
                const Spacer(),
                Text('Mar 15, 2025',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Grand Slam Court · Riyadh Sports Center',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (i) => IconButton(
                icon: Icon(Icons.star_border, color: const Color(0xFFF59E0B), size: 24),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),

              )),
            ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: () {},
              child: const Text('Submit Review',
                  style: TextStyle(color: Color(0xFF9BEC00), fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
      // Already Reviewed card
      Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                const Text('Already Reviewed',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1F2937))),
                const Spacer(),
                Text('Mar 10, 2025',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Pro Tennis Arena · Al Malaz Club',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
            const SizedBox(height: 6),
            Row(
              children: List.generate(4, (i) => const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16)),
            ),
            const SizedBox(height: 6),
            const Text('"Great match!"',
                style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    ] : <Widget>[];

    if (bookings.isEmpty && !showReviewCards) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(
              Ph.calendar_blank,
              size: 56,
              color: AppColors.lightMuted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            const Text(
              'No bookings yet',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: bookings.length + reviewCards.length,
      itemBuilder: (context, i) {
        if (i < reviewCards.length) return reviewCards[i];
        return BookingCard(booking: bookings[i - reviewCards.length]);
      },
    );
  }
}