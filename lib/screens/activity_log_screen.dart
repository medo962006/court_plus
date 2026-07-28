import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class ActivityLogScreen extends StatelessWidget {
  const ActivityLogScreen({super.key});

  // ── Static activity data ──
  static const _today = [
    (
      Ph.calendar_check_fill,
      'Booking Confirmed',
      'Today, 2:30 PM',
      'Court A · Eagle Sport · Singles · \$45.00',
      true,
    ),
    (
      Ph.tennis_ball_fill,
      'Match Played',
      'Today, 10:00 AM',
      'vs. Hafezs · 6–4, 7–5 · Open Match',
      false,
    ),
  ];

  static const _yesterday = [
    (
      Ph.star_fill,
      'Review Written',
      'Yesterday, 8:15 PM',
      'Eagle Sport · ★★★★☆ · "Amazing court!"',
      false,
    ),
    (
      Ph.calendar_check_fill,
      'Booking Confirmed',
      'Yesterday, 4:00 PM',
      'Court B · Green Valley Club · Doubles · \$60.00',
      true,
    ),
  ];

  static const _earlier = [
    (
      Ph.tennis_ball_fill,
      'Match Played',
      'Jun 24, 2026',
      'vs. Sara M. · 6–3, 6–2 · Open Match',
      false,
    ),
    (
      Ph.star_fill,
      'Review Written',
      'Jun 22, 2026',
      'Green Valley Club · ★★★★★ · "Top notch surface."',
      false,
    ),
    (
      Ph.calendar_check_fill,
      'Booking Confirmed',
      'Jun 20, 2026',
      'Court C · Sunrise Academy · Training · \$30.00',
      true,
    ),
    (
      Ph.user_plus_fill,
      'Invitation Accepted',
      'Jun 18, 2026',
      'You joined an open match hosted by Khaled A.',
      false,
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
        title: const Text('Activity Log',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Iconify(Ph.funnel, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _SectionHeader('Today'),
          ..._today.map((e) => _ActivityTile(
                icon: e.$1,
                title: e.$2,
                date: e.$3,
                details: e.$4,
                isNew: e.$5,
              )),
          _SectionHeader('Yesterday'),
          ..._yesterday.map((e) => _ActivityTile(
                icon: e.$1,
                title: e.$2,
                date: e.$3,
                details: e.$4,
                isNew: e.$5,
              )),
          _SectionHeader('Earlier'),
          ..._earlier.map((e) => _ActivityTile(
                icon: e.$1,
                title: e.$2,
                date: e.$3,
                details: e.$4,
                isNew: e.$5,
              )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 15,
              fontWeight: FontWeight.w700)),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String icon, title, date, details;
  final bool isNew;

  const _ActivityTile({
    required this.icon,
    required this.title,
    required this.date,
    required this.details,
    required this.isNew,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline icon with vertical line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isNew
                        ? AppColors.neonGreen.withValues(alpha: 0.15)
                        : AppColors.lightField,
                    shape: BoxShape.circle,
                  ),
                  child: Iconify(
                    icon,
                    size: 16,
                    color: isNew ? AppColors.darkSlate : AppColors.lightMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isNew ? AppColors.neonGreen : AppColors.lightBorder,
                  width: isNew ? 1.2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                      ),
                      if (isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('NEW',
                              style: TextStyle(
                                  color: AppColors.darkSlate,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(date,
                      style: const TextStyle(
                          color: AppColors.lightMuted, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(details,
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 13,
                          height: 1.35)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}