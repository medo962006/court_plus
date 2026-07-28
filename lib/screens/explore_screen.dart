import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  static const _recentSearches = [
    'Tennis courts',
    'Football pitch',
    'Coaches near me',
    'Open matches Riyadh',
  ];

  static const _trending = [
    ('assets/images/court1.jpg', 'Grand Slam Court', 'Riyadh Sports Center', 4.8),
    ('assets/images/court2.jpg', 'Pro Tennis Arena', 'Al Malaz Club', 4.6),
    ('assets/images/banner1.jpg', 'Football Pitch 1', 'Al Malaz Club', 4.2),
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
        title: const Text('Explore',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed(Routes.searchResults),
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
            const SizedBox(height: 24),
            const Text('Recent Searches',
                style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Iconify(Ph.clock_counter_clockwise, size: 14, color: AppColors.lightMuted),
                    const SizedBox(width: 6),
                    Text(s, style: const TextStyle(color: AppColors.lightText, fontSize: 13)),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Text('Trending Courts',
                style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ...List.generate(_trending.length, (i) {
              final t = _trending[i];
              return GestureDetector(
                onTap: () => Navigator.of(context).pushNamed(Routes.courtDetails),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                        child: Image.asset(t.$1, width: 100, height: 90, fit: BoxFit.cover),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.$2, style: const TextStyle(color: AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Text(t.$3, style: const TextStyle(color: AppColors.lightMuted, fontSize: 12)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Iconify(Ph.star_fill, size: 14, color: Color(0xFFFFB800)),
                                  const SizedBox(width: 4),
                                  Text('${t.$4}', style: const TextStyle(color: AppColors.lightText, fontSize: 12, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}