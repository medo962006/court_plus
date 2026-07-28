import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 2; // Home active
  int _chipIndex = 0;

  static const _chips = [
    ('All courts', Icons.sports_baseball),
    ('Tennis', Icons.sports_tennis),
    ('Football', Icons.sports_soccer),
    ('Padel', Icons.sports_cricket),
    ('Basketball', Icons.sports_basketball),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── Location header ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Location',
                            style: TextStyle(
                                color: AppColors.lightMuted, fontSize: 12)),
                        Row(
                          children: const [
                            Icon(Icons.location_on,
                                color: AppColors.lightText, size: 18),
                            SizedBox(width: 4),
                            Text('Riyadh, Saudi Arabia',
                                style: TextStyle(
                                    color: AppColors.lightText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                            Icon(Icons.keyboard_arrow_down,
                                color: AppColors.lightText, size: 20),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context)
                          .pushNamed(Routes.notifications),
                      child: Stack(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: const Color(0xFFE1E4E8)),
                          ),
                          child: const Icon(Icons.notifications_none,
                              color: AppColors.lightText),
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
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
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // ── Search bar ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE1E4E8)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: AppColors.lightMuted),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Find a courts, coaches + more',
                            hintStyle: TextStyle(
                                color: AppColors.lightMuted, fontSize: 14),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ],
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
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
                              _chips[i].$1,
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
                    const Text('Courts',
                        style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.courts),
                      child: const Text('See all',
                          style: TextStyle(
                              color: AppColors.lightMuted, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 210,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: const [
                    _CourtCard(
                      image: 'assets/images/court1.jpg',
                      title: 'Grand Slam Court',
                      center: 'Riyadh Sports Center',
                      distance: '1.2 km',
                      rating: 4.8,
                    ),
                    SizedBox(width: 14),
                    _CourtCard(
                      image: 'assets/images/court2.jpg',
                      title: 'Pro Tennis Arena',
                      center: 'Al Malaz Club',
                      distance: '2.5 km',
                      rating: 4.6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              // ── Quick action cards ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Play amazing Match',
                    style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: const [
                    Expanded(
                      child: _ActionCard(
                        image: 'assets/images/banner1.jpg',
                        label: 'Open match',
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: _ActionCard(
                        image: 'assets/images/banner2.jpg',
                        label: 'Coaches',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i) {
          if (i == 0) {
            Navigator.of(context).pushNamed(Routes.courts);
          } else {
            setState(() => _navIndex = i);
          }
        },
      ),
    );
  }
}

class _CourtCard extends StatelessWidget {
  final String image, title, center, distance;
  final double rating;

  const _CourtCard({
    required this.image,
    required this.title,
    required this.center,
    required this.distance,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
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
            child: Image.asset(image,
                height: 110, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(center,
                    style: const TextStyle(
                        color: AppColors.lightMuted, fontSize: 12)),
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
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String image, label;

  const _ActionCard({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Image.asset(image,
              height: 120, width: double.infinity, fit: BoxFit.cover),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.65)
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 12,
            bottom: 10,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    ('Courts', Icons.sports_tennis),
    ('Explore', Icons.explore_outlined),
    ('Home', Icons.home_filled),
    ('Activity', Icons.receipt_long_outlined),
    ('Profile', Icons.person_outline),
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
                      // Top indicator bar for active item
                      Container(
                        height: 3,
                        width: 28,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.neonGreen
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Icon(
                        _items[i].$2,
                        size: 24,
                        color: active
                            ? const Color(0xFF7CB800)
                            : AppColors.lightMuted,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _items[i].$1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? AppColors.lightText
                              : AppColors.lightMuted,
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