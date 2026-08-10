import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../presentation/providers/coach_provider.dart';
import '../core/widgets/skeletons.dart';
import '../services/models.dart';

class CoachesScreen extends ConsumerStatefulWidget {
  const CoachesScreen({super.key});

  @override
  ConsumerState<CoachesScreen> createState() => _CoachesScreenState();
}

class _CoachesScreenState extends ConsumerState<CoachesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'Highest Rated';

  static const _sortOptions = ['Highest Rated', 'Price Low', 'Price High'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachesProvider);

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
          'Coaches',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: const InputDecoration(
                  hintText: 'Search coaches...',
                  hintStyle: TextStyle(
                    color: AppColors.lightMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: Iconify(
                    Ph.magnifying_glass,
                    size: 20,
                    color: AppColors.lightMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Sort row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Sort by',
                  style: TextStyle(
                    color: AppColors.lightMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortBy,
                      icon: const Iconify(
                        Ph.caret_down_bold,
                        size: 14,
                        color: AppColors.lightText,
                      ),
                      items: _sortOptions.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: const TextStyle(
                              color: AppColors.lightText,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _sortBy = v);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Coach list
          Expanded(
            child: coachesAsync.when(
              data: (coaches) {
                var filtered = coaches;

                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered.where((c) =>
                      c.fullName.toLowerCase().contains(q) ||
                      c.sportType.toLowerCase().contains(q) ||
                      (c.bio?.toLowerCase().contains(q) ?? false)).toList();
                }

                switch (_sortBy) {
                  case 'Highest Rated':
                    filtered.sort((a, b) => b.rating.compareTo(a.rating));
                    break;
                  case 'Price Low':
                    filtered.sort((a, b) => a.pricePerSession.compareTo(b.pricePerSession));
                    break;
                  case 'Price High':
                    filtered.sort((a, b) => b.pricePerSession.compareTo(a.pricePerSession));
                    break;
                }

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Iconify(
                          Ph.user_circle,
                          size: 48,
                          color: AppColors.lightMuted,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No coaches found',
                          style: TextStyle(
                            color: AppColors.lightMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final coach = filtered[index];
                    return _CoachCard(
                      coach: coach,
                      onTap: () => Navigator.of(context).pushNamed(
                        Routes.coachDetails,
                        arguments: coach.id,
                      ),
                    );
                  },
                );
              },
              loading: () => const ShimmerList(itemCount: 4, itemHeight: 90),
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
                      'Failed to load coaches',
                      style: TextStyle(color: AppColors.lightText, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: const TextStyle(color: AppColors.lightMuted, fontSize: 13),
                      textAlign: TextAlign.center,
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

class _CoachCard extends StatelessWidget {
  final Coach coach;
  final VoidCallback onTap;

  const _CoachCard({required this.coach, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.darkSlate,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Iconify(
                  Ph.user_circle,
                  size: 36,
                  color: AppColors.lightMuted,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    coach.fullName,
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      coach.sportType,
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Iconify(
                        Ph.star_fill,
                        size: 14,
                        color: Color(0xFFFFB800),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${coach.rating}',
                        style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'SR ${coach.pricePerSession.toStringAsFixed(0)}/session',
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
}