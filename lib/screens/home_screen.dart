import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../l10n/app_strings.dart';
import '../services/event_tracker.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _navIndex = 2;
  int _chipIndex = 0;

  static const _chips = [
    ('All courts', Icons.sports_tennis),
    ('Tennis', Icons.sports_tennis),
    ('Football', Icons.sports_soccer),
    ('Padel', Icons.sports_handball),
    ('Basketball', Icons.sports_basketball),
  ];

  String _chipKey(String label) {
    return switch (label) {
      'All courts' => 'allCourts',
      'Tennis' => 'tennis',
      'Football' => 'football',
      'Padel' => 'padel',
      'Basketball' => 'basketball',
      _ => label,
    };
  }

  @override
  void initState() {
    super.initState();
    EventTracker.instance.track('screen_open', props: {'screen': 'home'});
  }

    @override
      Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
                  icon: const Iconify(Ph.chats_circle, size: 22, color: AppColors.lightText),
                  onPressed: () {},
                ),
        actions: [
          Stack(
            children: [
              IconButton(
                              icon: const Iconify(Ph.bell, size: 22, color: AppColors.lightText),
                              onPressed: () =>
                                  Navigator.of(context).pushNamed(Routes.notifications),
                            ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Location bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(AppStrings.of(context).t('location'),
                          style: const TextStyle(
                              color: AppColors.lightMuted, fontSize: 12)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: AppColors.neonGreen),
                          const SizedBox(width: 4),
                          Text(AppStrings.of(context).t('riyadhSaudiArabia'),
                              style: const TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600)),
                          const Icon(Icons.keyboard_arrow_down,
                              size: 18, color: AppColors.lightMuted),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Search bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushNamed(Routes.recentSearch),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.lightField,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search,
                          size: 20, color: AppColors.lightMuted),
                      const SizedBox(width: 10),
                      Text(
                        AppStrings.of(context).t('findCourtsCoaches'),
                        style: const TextStyle(
                            color: AppColors.lightMuted, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            // ── Category chips ──
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _chips.length,
                separatorBuilder: (context, i) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final active = i == _chipIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _chipIndex = i),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: active ? AppColors.neonGreen : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                            color: active
                                ? AppColors.neonGreen
                                : const Color(0xFFE1E4E8)),
                      ),
                      child: Row(
                        children: [
                          Icon(_chips[i].$2,
                              size: 18,
                              color: active
                                  ? Colors.black
                                  : AppColors.lightMuted),
                          const SizedBox(width: 6),
                          Text(
                            AppStrings.of(context).t(_chipKey(_chips[i].$1)),
                            style: TextStyle(
                              color: active
                                  ? Colors.black
                                  : AppColors.lightText,
                              fontSize: 13,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            // ── Courts section ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(AppStrings.of(context).t('courts'),
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () =>
                        Navigator.of(context).pushNamed(Routes.courts),
                    child: Text(AppStrings.of(context).t('seeAll'),
                        style: const TextStyle(
                            color: AppColors.lightMuted, fontSize: 13)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
                          height: 215,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _CourtCard(
                                      image: 'assets/images/court1.jpg',
                                      title: 'Grand Slam Court',
                                      center: 'Riyadh Sports Center',
                                      distance: '1.2 km',
                                      rating: 4.8,
                                      heroTag: 'court-Grand-Slam-Court',
                                      onTap: () => Navigator.of(context).pushNamed(Routes.courtDetails, arguments: 'court1'),
                  ),
                  const SizedBox(width: 14),
                  _CourtCard(
                                      image: 'assets/images/court2.jpg',
                                      title: 'Pro Tennis Arena',
                                      center: 'Al Malaz Club',
                                      distance: '2.5 km',
                                      rating: 4.6,
                                      heroTag: 'court-Pro-Tennis-Arena',
                                      onTap: () => Navigator.of(context).pushNamed(Routes.courtDetails, arguments: 'court2'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            // ── Quick action cards ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(AppStrings.of(context).t('playAmazingMatch'),
                  style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      image: 'assets/images/banner1.jpg',
                      label: AppStrings.of(context).t('openMatch'),
                      subtitle: 'If you are looking for player at your level',
                      onTap: () => Navigator.of(context).pushNamed(Routes.openMatches),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _ActionCard(
                      image: 'assets/images/banner2.jpg',
                      label: AppStrings.of(context).t('coaches'),
                      subtitle: 'Start your professional career',
                      onTap: () => Navigator.of(context).pushNamed(Routes.coaches),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushNamed(Routes.courts);
          } else if (i == 1) {
            Navigator.of(context).pushNamed(Routes.explore);
          } else if (i == 3) {
            Navigator.of(context).pushNamed(Routes.activity);
          } else if (i == 4) {
            Navigator.of(context).pushNamed(Routes.profile);
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }
}

// ─── Court Card ───

class _CourtCard extends StatelessWidget {
  final String image, title, center, distance;
  final double rating;
  final VoidCallback? onTap;
  final String heroTag;

    const _CourtCard({
      required this.image,
      required this.title,
      required this.center,
      required this.distance,
      required this.rating,
      required this.heroTag,
      this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
              width: 220,
              margin: const EdgeInsets.only(bottom: 2),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE1E4E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Hero(
                            tag: heroTag,
                            child: Image.asset(image,
                                                            height: 115, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ),
            Padding(
                          padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.lightMuted),
                      const SizedBox(width: 2),
                      Text(center,
                          style: const TextStyle(
                              color: AppColors.lightMuted, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.lightMuted),
                      Text(distance,
                          style: const TextStyle(
                              color: AppColors.lightMuted, fontSize: 12)),
                      const Spacer(),
                      const Icon(Icons.star,
                          size: 14, color: Color(0xFFFFB800)),
                      const SizedBox(width: 2),
                      Text('$rating',
                          style: const TextStyle(
                              color: AppColors.lightText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action Card (Open Match / Coaches) ───

class _ActionCard extends StatelessWidget {
  final String image, label, subtitle;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.image,
    required this.label,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 140,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(image, fit: BoxFit.cover),
                    // Dark gradient overlay at bottom
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Bottom overlay bar with icon + label
                    Positioned(
                      left: 12,
                      right: 12,
                      bottom: 10,
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: AppColors.neonGreen,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(Icons.sports_tennis,
                                  size: 16, color: Colors.black),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(label,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text(subtitle,
                  style: const TextStyle(
                      color: AppColors.lightMuted, fontSize: 13, height: 1.3)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Navigation ───

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  String _navKey(String label) {
    return switch (label) {
      'Courts' => 'courts',
      'Explore' => 'explore',
      'Home' => 'home',
      'Activity' => 'activity',
      'Profile' => 'profile',
      _ => label,
    };
  }

  static final _items = [
      ('Courts', Ph.tennis_ball),
      ('Explore', Ph.compass),
      ('Home', Ph.house_fill),
      ('Activity', Ph.receipt),
      ('Profile', Ph.user_circle),
    ];

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context).t;
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE1E4E8), width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: index,
        onTap: onTap,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: AppColors.lightMuted,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: _items.map((item) {
                  return BottomNavigationBarItem(
            icon: Iconify(item.$2, size: 22),
            label: t(_navKey(item.$1)),
          );
        }).toList(),
      ),
    );
  }
}