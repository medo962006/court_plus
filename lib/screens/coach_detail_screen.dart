import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/coach_provider.dart';
import '../presentation/providers/supabase_provider.dart';
import '../services/models.dart';

class CoachDetailScreen extends ConsumerWidget {
  const CoachDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coachId = ModalRoute.of(context)!.settings.arguments as String;
    final coachesAsync = ref.watch(coachesProvider);

    return coachesAsync.when(
      data: (coaches) {
        final coach = coaches.cast<Coach?>().firstWhere(
          (c) => c?.id == coachId,
          orElse: () => null,
        );
        if (coach == null) {
          return Scaffold(
            backgroundColor: AppColors.lightBg,
            appBar: _buildAppBar(context, ref),
            body: const Center(
              child: Text(
                'Coach not found',
                style: TextStyle(color: AppColors.lightMuted, fontSize: 16),
              ),
            ),
          );
        }
        return _CoachDetailBody(coach: coach);
      },
      loading: () => Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: _buildAppBar(context, ref),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.lightBg,
        appBar: _buildAppBar(context, ref),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Iconify(Ph.warning_circle, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Failed to load coach',
                style: TextStyle(color: AppColors.lightText, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: AppColors.lightBg,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Iconify(Ph.arrow_left, size: 22),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Coach Profile',
        style: TextStyle(
          color: AppColors.lightText,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Iconify(Ph.heart, size: 22),
          onPressed: () {
            final userId = ref.read(supabaseServiceProvider).currentUser?.id;
            if (userId == null) return;
            ref.read(supabaseServiceProvider).followUser(userId, 'coach');
          },
        ),
      ],
    );
  }
}

class _CoachDetailBody extends StatelessWidget {
  final Coach coach;
  const _CoachDetailBody({required this.coach});

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
        title: const Text(
          'Coach Profile',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Iconify(Ph.heart, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              children: [
                const SizedBox(height: 8),
                // Avatar + name row
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.darkSlate,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Iconify(
                          Ph.user_circle,
                          size: 48,
                          color: AppColors.lightMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            coach.fullName,
                            style: const TextStyle(
                              color: AppColors.lightText,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '@${coach.username}',
                            style: const TextStyle(
                              color: AppColors.lightMuted,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.neonGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              coach.sportType,
                              style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Stats row
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Ph.star_fill,
                        label: 'Rating',
                        value: coach.rating.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Ph.clock,
                        label: 'Experience',
                        value: '${coach.experience} years',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Ph.money,
                        label: 'Per session',
                        value: 'SR ${coach.pricePerSession.toStringAsFixed(0)}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Bio section
                const Text(
                  'About',
                  style: TextStyle(
                    color: AppColors.lightText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  coach.bio ?? 'No bio available.',
                  style: const TextStyle(
                    color: AppColors.lightMuted,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // Book CTA
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.lightBorder)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.neonGreen,
                    foregroundColor: AppColors.darkText,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking session with ${coach.fullName}...'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text('Book Session — SR ${coach.pricePerSession.toStringAsFixed(0)}'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Iconify(icon, size: 22, color: AppColors.lightText),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.lightMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}