import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({super.key});

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
    (
      'assets/images/court1.jpg',
      'Basketball Court A',
      'North Arena',
      '1.8km away',
      4.6
    ),
    (
      'assets/images/court2.jpg',
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
          icon: const Iconify(Ph.arrow_left, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Search Results',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── Search bar ──
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
                    child: Row(
                      children: [
                        const Iconify(Ph.magnifying_glass,
                            size: 20, color: AppColors.lightMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Tennis court',
                              hintStyle: const TextStyle(
                                  color: AppColors.lightText, fontSize: 14),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                        const Iconify(Ph.x_circle_fill,
                            size: 18, color: AppColors.lightMuted),
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
                const SizedBox(width: 10),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: const Center(
                      child: Iconify(Ph.arrows_down_up,
                          size: 20, color: AppColors.lightText)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Results count ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: const [
                Text('12 results found',
                    style: TextStyle(
                        color: AppColors.lightMuted, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // ── Results list ──
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: _courts.length,
              separatorBuilder: (context, i) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final c = _courts[i];
                return _SearchResultCard(
                  image: c.$1,
                  title: c.$2,
                  center: c.$3,
                  distance: c.$4,
                  rating: c.$5,
                  onTap: () =>
                      Navigator.of(context).pushNamed(Routes.courtDetails),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  final String image, title, center, distance;
  final double rating;
  final VoidCallback onTap;

  const _SearchResultCard({
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
        child: Row(
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.asset(image,
                  width: 100, height: 100, fit: BoxFit.cover),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(title,
                              style: const TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                        ),
                        const Iconify(Ph.heart,
                            size: 18, color: AppColors.lightMuted),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(center,
                        style: const TextStyle(
                            color: AppColors.lightMuted, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Iconify(Ph.map_pin,
                            size: 14, color: AppColors.lightMuted),
                        const SizedBox(width: 2),
                        Text(distance,
                            style: const TextStyle(
                                color: AppColors.lightMuted, fontSize: 12)),
                        const Spacer(),
                        const Iconify(Ph.star_fill,
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
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}