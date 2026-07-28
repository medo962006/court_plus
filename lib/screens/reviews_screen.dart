import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  // PLACEHOLDER IMAGES NEEDED:
  // - assets/images/avatar_1.jpg → male reviewer headshot
  // - assets/images/avatar_2.jpg → female reviewer headshot
  // - assets/images/avatar_3.jpg → male reviewer headshot (different)
  static const _reviews = [
    (
      'Eagle Sport',
      '@eaglesport',
      '2 mins ago',
      5,
      'Amazing court! The surface is well maintained and the lighting at night is perfect. Highly recommend booking early on weekends.'
    ),
    (
      'Sara M.',
      '@sara_m',
      '3 hours ago',
      4,
      'Great experience overall. Booking was smooth. Only downside is parking gets crowded after 6pm.'
    ),
    (
      'Khaled A.',
      '@khaled9',
      '1 day ago',
      3,
      'Court is decent but the nets need replacing. Staff was friendly and helpful though.'
    ),
    (
      'Hafez S.',
      '@Hafezs',
      '3 days ago',
      5,
      'Best tennis court in Riyadh! Played an open match here — surface quality is top notch.'
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
        title: const Text('Reviews',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // ── Summary card ──
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Row(
              children: [
                Column(
                  children: [
                    const Text('4.0',
                        style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 44,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Iconify(
                          i < 4 ? Ph.star_fill : Ph.star,
                          size: 16,
                          color: const Color(0xFFFFB800),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('26 reviews',
                        style: TextStyle(
                            color: AppColors.lightMuted, fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final star = 5 - i;
                      const fractions = [0.65, 0.20, 0.08, 0.04, 0.03];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Text('$star',
                                style: const TextStyle(
                                    color: AppColors.lightMuted,
                                    fontSize: 12)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: fractions[i],
                                  minHeight: 6,
                                  backgroundColor: AppColors.lightField,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          AppColors.neonGreen),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // ── Review list ──
          ..._reviews.map((r) => _ReviewCard(
                name: r.$1,
                handle: r.$2,
                time: r.$3,
                stars: r.$4,
                comment: r.$5,
              )),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final String name, handle, time, comment;
  final int stars;

  const _ReviewCard({
    required this.name,
    required this.handle,
    required this.time,
    required this.stars,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: AppColors.lightField,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    color: AppColors.lightMuted, size: 22),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  Text('$handle · $time',
                      style: const TextStyle(
                          color: AppColors.lightMuted, fontSize: 12)),
                ],
              ),
              const Spacer(),
              Row(
                children: List.generate(
                  5,
                  (i) => Iconify(
                    i < stars ? Ph.star_fill : Ph.star,
                    size: 13,
                    color: const Color(0xFFFFB800),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(comment,
              style: const TextStyle(
                  color: AppColors.lightText, fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }
}