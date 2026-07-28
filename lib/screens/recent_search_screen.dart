import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class RecentSearchScreen extends StatefulWidget {
  const RecentSearchScreen({super.key});

  @override
  State<RecentSearchScreen> createState() => _RecentSearchScreenState();
}

class _RecentSearchScreenState extends State<RecentSearchScreen> {
  int _navIndex = 1;
  int _tabIndex = 0; // 0 = Courts, 1 = Coaches
  int _chipIndex = 0; // 0 = All courts, 1 = Tennis, 2 = Football

  static const _tabs = ['Courts', 'Coaches'];
  static const _chips = ['All courts', 'Tennis', 'Football'];

  static const _recentItems = [
    (
      'Tennis Outdoor Court A',
      'Eagle Sport Center',
      '3km away',
      4.5
    ),
    (
      'Tennis Indoor Court B',
      'Riyadh Sports Hub',
      '5km away',
      4.8
    ),
    (
      'Football Pitch 1',
      'Al Malaz Club',
      '2km away',
      4.2
    ),
    (
      'Basketball Court A',
      'North Arena',
      '1.8km away',
      4.6
    ),
    (
      'Padel Court 3',
      'Padel Zone',
      '4km away',
      4.3
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.chats_circle, size: 22, color: AppColors.lightText),
          onPressed: () {},
        ),
        title: const Text('Explore',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Iconify(Ph.bell, size: 22, color: AppColors.lightText),
                onPressed: () => Navigator.of(context).pushNamed(Routes.notifications),
              ),
              Positioned(
                right: 10,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: const Row(
                children: [
                  Iconify(Ph.magnifying_glass, size: 20, color: AppColors.lightMuted),
                  SizedBox(width: 10),
                  Text('Find a courts, coaches + more',
                      style: TextStyle(color: AppColors.lightMuted, fontSize: 14)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── Category tabs ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == _tabIndex;
                return GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: active ? AppColors.neonGreen : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                    ),
                    child: Text(
                      _tabs[i],
                      style: TextStyle(
                        color: active ? AppColors.lightText : AppColors.lightMuted,
                        fontSize: 15,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // ── Filter chips ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                ...List.generate(_chips.length, (i) {
                  final active = i == _chipIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _chipIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.neonGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? AppColors.neonGreen : AppColors.lightBorder,
                        ),
                      ),
                      child: Text(
                        _chips[i],
                        style: TextStyle(
                          color: active ? AppColors.darkText : AppColors.lightMuted,
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Recent section header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text('Recent',
                    style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Iconify(Ph.funnel, size: 18, color: AppColors.lightText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // ── Recent list items ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _recentItems.length,
              separatorBuilder: (context, i) => const SizedBox(height: 2),
              itemBuilder: (context, i) {
                final item = _recentItems[i];
                return _RecentSearchItem(
                  title: item.$1,
                  center: item.$2,
                  distance: item.$3,
                  rating: item.$4,
                  onTap: () => Navigator.of(context).pushNamed(Routes.searchResults),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 0) Navigator.of(context).pushReplacementNamed(Routes.courts);
          if (i == 2) Navigator.of(context).pushReplacementNamed(Routes.home);
          if (i == 3) Navigator.of(context).pushReplacementNamed(Routes.activity);
          if (i == 4) Navigator.of(context).pushReplacementNamed(Routes.profile);
        },
      ),
    );
  }
}

class _RecentSearchItem extends StatelessWidget {
  final String title, center, distance;
  final double rating;
  final VoidCallback onTap;

  const _RecentSearchItem({
    required this.title,
    required this.center,
    required this.distance,
    required this.rating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            // Clock history icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.lightField,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Iconify(Ph.clock_counter_clockwise,
                    size: 18, color: AppColors.lightMuted),
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Iconify(Ph.map_pin, size: 12, color: AppColors.lightMuted),
                      const SizedBox(width: 4),
                      Text(center,
                          style: const TextStyle(color: AppColors.lightMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            // Rating and distance
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Iconify(Ph.star_fill, size: 12, color: Color(0xFFFFB800)),
                    const SizedBox(width: 2),
                    Text('$rating',
                        style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(distance,
                    style: const TextStyle(color: AppColors.lightMuted, fontSize: 11)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    ('Courts', Ph.tennis_ball),
    ('Explore', Ph.compass),
    ('Home', Ph.house_fill),
    ('Activity', Ph.receipt),
    ('Profile', Ph.user_circle),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE1E4E8))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (i) {
              final active = i == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 3,
                        width: 28,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.neonGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Iconify(
                        _items[i].$2,
                        size: 24,
                        color: active ? const Color(0xFF7CB800) : AppColors.lightMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.lightText : AppColors.lightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}