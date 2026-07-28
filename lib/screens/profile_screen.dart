import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class ProfileScreen extends StatelessWidget {
  final bool isOwnProfile;

  const ProfileScreen({super.key, this.isOwnProfile = true});

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
        title: const Text('Profile',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        actions: [
          if (isOwnProfile)
            IconButton(
              icon: const Iconify(Ph.gear_six, size: 22),
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.settings),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Profile header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  // Avatar
                  Stack(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.lightField,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(BorderSide(
                              color: AppColors.neonGreen, width: 3)),
                        ),
                        child: const Icon(Icons.person,
                            color: AppColors.lightMuted, size: 40),
                      ),
                      if (isOwnProfile)
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context)
                                .pushNamed(Routes.updateProfile),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                color: AppColors.lightText,
                                shape: BoxShape.circle,
                              ),
                              child: const Iconify(Ph.pencil_simple,
                                  size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Name and username
                  const Text('Alex Rivera',
                      style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('@alexrivera',
                      style: TextStyle(
                          color: AppColors.lightMuted, fontSize: 14)),
                  const SizedBox(height: 8),
                  const Text('Love the game. Tennis & padel enthusiast 🎾',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 13,
                          height: 1.4)),
                  if (!isOwnProfile) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightText,
                          minimumSize: const Size.fromHeight(48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Follow',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // ── Stats row ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  _StatItem(label: 'Matches', value: '47'),
                  _StatItem(label: 'Courts', value: '12'),
                  _StatItem(label: 'Followers', value: '1.2k', hasBorder: false),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // ── My Profile section header ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text('My Profile',
                      style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('View all',
                      style: TextStyle(
                          color: AppColors.lightMuted, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ── Activity feed ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: const [
                  _ActivityCard(
                    icon: Ph.tennis_ball_fill,
                    title: 'Booked Tennis Court A',
                    subtitle: 'Eagle Sport Center • Today, 10:00 AM',
                  ),
                  SizedBox(height: 12),
                  _ActivityCard(
                    icon: Ph.users_three_fill,
                    title: 'Joined Open Match',
                    subtitle: 'Padel Court 3 • Yesterday, 6:00 PM',
                  ),
                  SizedBox(height: 12),
                  _ActivityCard(
                    icon: Ph.star_fill,
                    title: 'Reviewed Court B',
                    subtitle: 'Riyadh Sports Hub • 2 days ago',
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final bool hasBorder;

  const _StatItem({
    required this.label,
    required this.value,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          border: hasBorder
              ? const Border(
                  right: BorderSide(color: AppColors.lightBorder))
              : null,
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    color: AppColors.lightText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: AppColors.lightMuted, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String icon, title, subtitle;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.lightField,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Iconify(icon, size: 20, color: AppColors.lightText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.lightMuted, fontSize: 12)),
              ],
            ),
          ),
          const Iconify(Ph.caret_right,
              size: 16, color: AppColors.lightMuted),
        ],
      ),
    );
  }
}