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
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.lightField,
            backgroundImage: const AssetImage('assets/images/avatar.png'),
            child: const Icon(Icons.person, color: AppColors.lightMuted, size: 20),
          ),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Iconify(Ph.dots_three_outline, size: 22),
            color: AppColors.lightText,
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Cover Photo + Avatar ──
            SizedBox(
              height: 180,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover photo
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: AppColors.lightField,
                    ),
                    child: const Center(
                      child: Icon(Icons.image_outlined, color: AppColors.lightMuted, size: 40),
                    ),
                  ),
                  // "Update" button on cover
                  Positioned(
                    bottom: 48,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(Routes.updateProfile),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Iconify(Ph.pencil_simple, size: 12, color: AppColors.lightText),
                            SizedBox(width: 4),
                            Text(
                              'Update',
                              style: TextStyle(
                                color: AppColors.lightText,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Profile pic overlapping cover
                  Positioned(
                    bottom: -4,
                    left: 20,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 39,
                            backgroundColor: AppColors.lightField,
                            backgroundImage: const AssetImage('assets/images/avatar.png'),
                            child: const Icon(Icons.person, color: AppColors.lightMuted, size: 36),
                          ),
                        ),
                        // Green online dot
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.neonGreen,
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
            const SizedBox(height: 20),

            // ── Following / Followers Stats ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Spacer(),
                  Column(
                    children: const [
                      Text(
                        '975',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Following',
                        style: TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 48),
                  Column(
                    children: const [
                      Text(
                        '1.6K',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Follower',
                        style: TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Name & Handle ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    'Justin Nurmagomedov',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    '@justinnurmagomedov',
                    style: TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Bio ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Professional athlete & sports enthusiast. '
                'Love competing and exploring new courts around the world.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Interest Pills ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: const [
                  _InterestPill(emoji: '🎾', label: 'Tennis', level: 'Amateur'),
                  _InterestPill(emoji: '⚽', label: 'Football', level: 'Advanced'),
                  _InterestPill(emoji: '🚲', label: 'Pedal', level: 'Amateur'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Play Stats Row ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  _PlayStatItem(
                    icon: Ph.tennis_ball_fill,
                    value: '5',
                    label: 'courts played',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.lightBorder,
                  ),
                  _PlayStatItem(
                    icon: Ph.clock_fill,
                    value: '8 hrs',
                    label: 'court times',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.lightBorder,
                  ),
                  _PlayStatItem(
                    icon: Ph.users_fill,
                    value: '8',
                    label: 'sessions',
                    hasBorder: false,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── My Moments Section ──
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    'My Moments',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Iconify(Ph.caret_right, size: 18, color: AppColors.lightMuted),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Green underline
            Container(
              margin: const EdgeInsets.only(left: 20),
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.neonGreen,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // ── Moment Post Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Moment image
                    Container(
                      height: 180,
                      width: double.infinity,
                      color: AppColors.lightField,
                      child: const Center(
                        child: Icon(Icons.image_outlined, color: AppColors.lightMuted, size: 44),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Morning bright for Tennis Day',
                            style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Iconify(Ph.clock, size: 14, color: AppColors.lightMuted),
                              const SizedBox(width: 4),
                              const Text(
                                '3 days ago',
                                style: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Iconify(
                                Ph.heart,
                                size: 18,
                                color: AppColors.lightMuted,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '24',
                                style: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Iconify(
                                Ph.chat_circle_dots,
                                size: 18,
                                color: AppColors.lightMuted,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                '8',
                                style: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      // ── Bottom Navigation ──
      bottomNavigationBar: _ProfileBottomNav(index: 4),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _InterestPill extends StatelessWidget {
  final String emoji;
  final String label;
  final String level;

  const _InterestPill({
    required this.emoji,
    required this.label,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.neonGreenAlt.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              '•',
              style: TextStyle(
                color: AppColors.lightMuted,
                fontSize: 12,
              ),
            ),
          ),
          Text(
            level,
            style: const TextStyle(
              color: AppColors.lightMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayStatItem extends StatelessWidget {
  final String icon, value, label;
  final bool hasBorder;

  const _PlayStatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(icon, size: 16, color: AppColors.lightText),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.lightMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBottomNav extends StatelessWidget {
  final int index;

  const _ProfileBottomNav({required this.index});

  static const _items = [
    ('Courts', Icons.sports_tennis),
    ('Explore', Icons.explore_outlined),
    ('Home', Icons.home_filled),
    ('Activity', Icons.receipt_long_outlined),
    ('Profile', Icons.person),
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
                  onTap: () {
                    if (i == 2) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.home, (_) => false,
                      );
                    }
                  },
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
                      Icon(
                        i == 4 ? Icons.person : _items[i].$2,
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