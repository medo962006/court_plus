import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class CourtsScreen extends StatefulWidget {
  const CourtsScreen({super.key});

  @override
  State<CourtsScreen> createState() => _CourtsScreenState();
}

class _CourtsScreenState extends State<CourtsScreen> {
  int _chipIndex = 0;

  static const _chips = [
    ('All courts', Ph.circles_four),
    ('Tennis', Ph.tennis_ball),
    ('Football', Ph.soccer_ball),
    ('Padel', Ph.circle_wavy),
    ('Basketball', Ph.basketball),
  ];

  // PLACEHOLDER IMAGES NEEDED:
  // - assets/images/court_tennis_a.jpg  → outdoor tennis court, green surface, daytime
  // - assets/images/court_tennis_b.jpg  → indoor tennis court, night lighting
  // - assets/images/court_football.jpg  → 5-a-side football pitch, artificial turf
  static const _courts = [
    (
      'assets/images/court1.jpg',
      'Tennis Outdoor Court A',
      'Eagle Sport Center',
      '3km away',
      4.5
    ),
    (
      'assets/images/court2.jpg',
      'Tennis Indoor Court B',
      'Riyadh Sports Hub',
      '5km away',
      4.8
    ),
    (
      'assets/images/banner1.jpg',
      'Football Pitch 1',
      'Al Malaz Club',
      '2km away',
      4.2
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Location',
                          style: TextStyle(
                              color: AppColors.lightMuted, fontSize: 12)),
                      Row(
                        children: [
                          Iconify(Ph.map_pin_fill,
                              size: 16, color: AppColors.lightText),
                          SizedBox(width: 4),
                          Text('Riyadh, Saudi Arabia',
                              style: TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          Iconify(Ph.caret_down_bold,
                              size: 14, color: AppColors.lightText),
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
                            border: Border.all(color: AppColors.lightBorder),
                          ),
                          child: const Center(
                              child: Iconify(Ph.bell,
                                  size: 22, color: AppColors.lightText)),
                        ),
                        Positioned(
                          top: 10,
                          right: 12,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── Search + filter ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: const Row(
                        children: [
                          Iconify(Ph.magnifying_glass,
                              size: 20, color: AppColors.lightMuted),
                          SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Find a courts, coaches + more',
                                hintStyle: TextStyle(
                                    color: AppColors.lightMuted,
                                    fontSize: 13),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.darkSlate,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                        child: Iconify(Ph.sliders_horizontal,
                            size: 20, color: AppColors.neonGreen)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── Chips ──
            SizedBox(
              height: 40,
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
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: active ? AppColors.neonGreen : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: active
                                ? AppColors.neonGreen
                                : AppColors.lightBorder),
                      ),
                      child: Row(
                        children: [
                          Iconify(_chips[i].$2,
                              size: 16,
                              color: active
                                  ? Colors.black
                                  : AppColors.lightMuted),
                          const SizedBox(width: 6),
                          Text(_chips[i].$1,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? Colors.black
                                      : AppColors.lightText)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            // ── Vertical feed ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                itemCount: _courts.length,
                separatorBuilder: (context, i) => const SizedBox(height: 16),
                itemBuilder: (context, i) {
                  final c = _courts[i];
                  return _CourtFeedCard(
                    image: c.$1,
                    title: c.$2,
                    center: c.$3,
                    distance: c.$4,
                    rating: c.$5,
                    onTap: () => Navigator.of(context)
                        .pushNamed(Routes.courtDetails),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourtFeedCard extends StatelessWidget {
  final String image, title, center, distance;
  final double rating;
  final VoidCallback onTap;

  const _CourtFeedCard({
    required this.image,
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(image,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6),
                      ],
                    ),
                    child: const Center(
                        child: Iconify(Ph.heart,
                            size: 18, color: AppColors.lightText)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                      const Iconify(Ph.star_fill,
                          size: 16, color: Color(0xFFFFB800)),
                      const SizedBox(width: 4),
                      Text('$rating',
                          style: const TextStyle(
                              color: AppColors.lightText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(center,
                          style: const TextStyle(
                              color: AppColors.lightMuted, fontSize: 13)),
                      const Spacer(),
                      const Iconify(Ph.map_pin,
                          size: 14, color: AppColors.lightMuted),
                      const SizedBox(width: 2),
                      Text(distance,
                          style: const TextStyle(
                              color: AppColors.lightMuted, fontSize: 12)),
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