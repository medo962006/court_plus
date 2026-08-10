import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/moments_provider.dart';
import '../presentation/providers/social_provider.dart';
import '../presentation/providers/supabase_provider.dart';
import '../services/models.dart';
import '../routes.dart';
import '../core/widgets/skeletons.dart';

class MomentsScreen extends ConsumerStatefulWidget {
  const MomentsScreen({super.key});

  @override
  ConsumerState<MomentsScreen> createState() => _MomentsScreenState();
}

class _MomentsScreenState extends ConsumerState<MomentsScreen> {
  // Use a simple column layout since flutter_staggered_grid_view is not a dependency.
  // For production, add flutter_staggered_grid_view to pubspec.yaml and swap to MasonryGridView.
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final momentsAsync = ref.watch(momentsProvider);

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
        title: const Text(
          'Moments',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Iconify(Ph.plus_circle, size: 22),
            onPressed: () async {
              final created = await Navigator.of(context).pushNamed(
                Routes.createMoment,
              );
              if (created == true && mounted) {
                ref.invalidate(momentsProvider);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab chips: Latest / Popular
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _TabChip(
                  label: 'Latest',
                  active: _selectedTab == 0,
                  onTap: () => setState(() => _selectedTab = 0),
                ),
                const SizedBox(width: 10),
                _TabChip(
                  label: 'Popular',
                  active: _selectedTab == 1,
                  onTap: () => setState(() => _selectedTab = 1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // Moments grid
          Expanded(
            child: momentsAsync.when(
              data: (moments) {
                var display = moments;
                if (_selectedTab == 1) {
                  display = List.from(moments)
                    ..sort((a, b) => b.likesCount.compareTo(a.likesCount));
                }

                if (display.isEmpty) {
                  display = [
                    Moment(id: 'mock1', userId: 'u1', imageUrl: 'https://i.pravatar.cc/400?u=mock1', caption: 'Great day on the court!', likesCount: 24, createdAt: DateTime.now().toIso8601String()),
                    Moment(id: 'mock2', userId: 'u2', imageUrl: 'https://i.pravatar.cc/400?u=mock2', caption: 'Weekend tennis session', likesCount: 18, createdAt: DateTime.now().toIso8601String()),
                    Moment(id: 'mock3', userId: 'u3', imageUrl: 'https://i.pravatar.cc/400?u=mock3', caption: 'New personal best!', likesCount: 42, createdAt: DateTime.now().toIso8601String()),
                  ];
                }

                // Custom masonry-like grid: distribute items across two columns
                final col1 = <Moment>[];
                final col2 = <Moment>[];
                for (int i = 0; i < display.length; i++) {
                  if (i.isEven) {
                    col1.add(display[i]);
                  } else {
                    col2.add(display[i]);
                  }
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: col1.map((m) => _MomentCard(moment: m)).toList(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          children: col2.map((m) => _MomentCard(moment: m)).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const ShimmerList(itemCount: 4, itemHeight: 100),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Iconify(
                      Ph.warning_circle,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to load moments',
                      style: TextStyle(color: AppColors.lightText, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.neonGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.neonGreen : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active ? Colors.black : AppColors.lightText,
          ),
        ),
      ),
    );
  }
}

class _MomentCard extends ConsumerWidget {
  final Moment moment;

  const _MomentCard({required this.moment});

  void _showCommentDialog(BuildContext context, WidgetRef ref, String momentId) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add a comment'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Write your comment...'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                final userId = ref.read(supabaseServiceProvider).currentUser?.id;
                if (userId != null) {
                  ref.read(supabaseServiceProvider).addMomentComment(momentId, userId, ctrl.text.trim());
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: moment.id.hashCode.isEven ? 1.0 : 0.8,
              child: Image.network(
                moment.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.darkSlate,
                  child: const Center(
                    child: Iconify(
                      Ph.warning_circle,
                      size: 32,
                      color: AppColors.lightMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Caption and likes
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (moment.caption != null && moment.caption!.isNotEmpty)
                  Text(
                    moment.caption!,
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 12,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        final userId = ref.read(supabaseServiceProvider).currentUser?.id;
                        if (userId == null) return;
                        ref.read(momentLikeNotifierProvider(moment.id).notifier).toggle();
                      },
                      child: Iconify(
                        Ph.heart_fill,
                        size: 14,
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${moment.likesCount}',
                      style: const TextStyle(
                        color: AppColors.lightMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Comment button
                    GestureDetector(
                      onTap: () => _showCommentDialog(context, ref, moment.id),
                      child: const Iconify(
                        Ph.chat_circle,
                        size: 14,
                        color: AppColors.lightMuted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Share button
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share coming soon')),
                        );
                      },
                      child: const Iconify(
                        Ph.share,
                        size: 14,
                        color: AppColors.lightMuted,
                      ),
                    ),
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