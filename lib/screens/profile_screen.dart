import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/moments_provider.dart';
import '../core/widgets/animations.dart';
import '../services/models.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isOwnProfile;

  const ProfileScreen({super.key, this.isOwnProfile = true});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final momentsAsync = ref.watch(momentsProvider);
    final user = authState.user;
    final moments = momentsAsync.value ?? <Moment>[];

    // Dynamic user data
    final displayName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Player';
    final displayHandle = user?.username.isNotEmpty == true ? '@${user!.username}' : '@player';
    final displayBio = (user?.bio?.isNotEmpty == true ? user!.bio! : 'Sports enthusiast');
    final followingCount = user?.followingCount ?? 0;
    final followersCount = user?.followersCount ?? 0;
    final matchesCount = user?.matchesCount ?? 0;
    final courtsCount = user?.courtsCount ?? 0;

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
                    child: const Icon(Icons.person, color: AppColors.lightMuted, size: 20),
                  ),
                ),
                title: Text(
          widget.isOwnProfile ? 'My Profile' : displayName,
          style: const TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (widget.isOwnProfile)
            IconButton(
              icon: const Iconify(Ph.dots_three_outline, size: 22),
              color: AppColors.lightText,
              onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
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
                    decoration: BoxDecoration(
                      color: AppColors.lightField,
                      image: user?.headerUrl != null
                          ? DecorationImage(
                              image: NetworkImage(user!.headerUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: user?.headerUrl == null
                        ? const Center(
                            child: Icon(Icons.image_outlined, color: AppColors.lightMuted, size: 40),
                          )
                        : null,
                  ),
                  // "Update" button on cover
                  if (widget.isOwnProfile)
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
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
                            backgroundImage: user?.avatarUrl != null
                                ? NetworkImage(user!.avatarUrl!)
                                : null,
                            child: user?.avatarUrl == null
                                ? const Icon(Icons.person, color: AppColors.lightMuted, size: 36)
                                : null,
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
                    children: [
                      Text(
                        _formatCount(followingCount),
                        style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
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
                    children: [
                      Text(
                        _formatCount(followersCount),
                        style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displayHandle,
                    style: const TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Bio ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                displayBio,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.lightText,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 16),

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
                                      valueWidget: AnimatedCount(target: courtsCount, style: const TextStyle(color: AppColors.lightText, fontSize: 18, fontWeight: FontWeight.w700)),
                                      label: 'courts played',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.lightBorder,
                  ),
                  _PlayStatItem(
                    icon: Ph.clock_fill,
                    valueWidget: AnimatedCount(target: matchesCount, style: const TextStyle(color: AppColors.lightText, fontSize: 18, fontWeight: FontWeight.w700)),
                                        label: 'court times',
                  ),
                  Container(
                    width: 1,
                    height: 32,
                    color: AppColors.lightBorder,
                  ),
                  _PlayStatItem(
                    icon: Ph.users_fill,
                    valueWidget: AnimatedCount(target: matchesCount, style: const TextStyle(color: AppColors.lightText, fontSize: 18, fontWeight: FontWeight.w700)),
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

            // ── Moments Grid ──
            if (moments.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                child: Center(
                  child: Column(
                    children: [
                      Iconify(Ph.image, size: 40, color: AppColors.lightMuted),
                      const SizedBox(height: 12),
                      const Text(
                        'No moments yet',
                        style: TextStyle(color: AppColors.lightMuted, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Share your first moment!',
                        style: TextStyle(color: AppColors.lightMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...moments.take(3).map((moment) => _MomentCard(moment: moment)),

            const SizedBox(height: 24),
          ],
        ),
      ),
      // ── Bottom Navigation ──
      bottomNavigationBar: _ProfileBottomNav(index: 4),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}

// ─── Moment Card ───

class _MomentCard extends StatelessWidget {
  final Moment moment;

  const _MomentCard({required this.moment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
              decoration: BoxDecoration(
                color: AppColors.lightField,
                image: moment.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(moment.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: moment.imageUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.image_outlined, color: AppColors.lightMuted, size: 44),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moment.caption ?? 'No caption',
                    style: const TextStyle(
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
                      Text(
                        moment.createdAt.isNotEmpty
                            ? _relativeTime(DateTime.parse(moment.createdAt))
                            : '',
                        style: const TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      const Iconify(
                        Ph.heart,
                        size: 18,
                        color: AppColors.lightMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${moment.likesCount}',
                        style: const TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Iconify(
                        Ph.chat_circle_dots,
                        size: 18,
                        color: AppColors.lightMuted,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        '0',
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
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'now';
  }
}

// ─── Supporting widgets ───

class _PlayStatItem extends StatelessWidget {
  final String icon, label;
  final Widget? valueWidget;
  final bool hasBorder;

  const _PlayStatItem({
    required this.icon,
    this.valueWidget,
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
                                                valueWidget ?? const Text(
                                                  '',
                                                  style: TextStyle(
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