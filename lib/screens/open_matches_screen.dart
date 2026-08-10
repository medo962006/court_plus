import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../presentation/providers/supabase_provider.dart';
import '../services/models.dart';

/// Provider that fetches open/upcoming matches from Supabase.
final openMatchesProvider = FutureProvider<List<Match>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getUserMatches();
  return result.fold(
    (matches) => matches,
    (_) => <Match>[],
  );
});

class OpenMatchesScreen extends ConsumerWidget {
  const OpenMatchesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchesAsync = ref.watch(openMatchesProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22),
          color: AppColors.lightText,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Open match',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Iconify(Ph.list_bullets, size: 22),
            color: AppColors.lightText,
            onPressed: () {},
          ),
          IconButton(
            icon: const Iconify(Ph.funnel, size: 22),
            color: AppColors.lightText,
            onPressed: () {},
          ),
        ],
      ),
      body: matchesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Iconify(Ph.warning_circle, size: 40, color: AppColors.lightMuted),
              const SizedBox(height: 12),
              Text('Could not load matches', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
        data: (matches) {
          if (matches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Iconify(Ph.soccer_ball, size: 48, color: AppColors.lightMuted),
                  const SizedBox(height: 16),
                  const Text(
                    'No open matches yet',
                    style: TextStyle(color: AppColors.lightMuted, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Create a match to get started!',
                    style: TextStyle(color: AppColors.lightMuted, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Ready for amazing match',
                    style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('These matches fit your search and your level',
                    style: TextStyle(color: AppColors.lightMuted, fontSize: 14)),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  itemCount: matches.length,
                  itemBuilder: (context, index) => _MatchCard(
                    match: matches[index],
                    onTap: () {},
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(Routes.startMatch),
        backgroundColor: AppColors.neonGreen,
        foregroundColor: AppColors.darkText,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        icon: const Iconify(Ph.plus, size: 20),
        label: const Text('Start a Match',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const _MatchCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: court name + badge
              Row(
                children: [
                  Text(match.courtName,
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 17,
                          fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.neonGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Iconify(Ph.check, size: 12,
                            color: AppColors.darkSlate),
                        const SizedBox(width: 4),
                        Text(match.level,
                            style: const TextStyle(
                                color: AppColors.darkSlate,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Player slots
              Row(
                children: [
                  ...List.generate(match.currentPlayers, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.lightField,
                            child: Icon(Icons.person,
                                size: 20, color: AppColors.lightMuted),
                          ),
                          const SizedBox(height: 4),
                          const Text('Player',
                              style: TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    );
                  }),
                  ...List.generate(match.maxPlayers - match.currentPlayers, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.lightField,
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: AppColors.lightBorder, width: 1.5),
                            ),
                            child: const Icon(Icons.add,
                                size: 20, color: AppColors.lightMuted),
                          ),
                          const SizedBox(height: 4),
                          const Text('Available',
                              style: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 11)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 14),

              // Date/time
              Row(
                children: [
                  const Iconify(Ph.clock, color: AppColors.lightText, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${match.date} · ${match.timeSlot}',
                    style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // Location
              Row(
                children: [
                  const Iconify(Ph.map_pin,
                      color: AppColors.lightMuted, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(match.location,
                        style: const TextStyle(
                            color: AppColors.lightMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Price + Book now
              Row(
                children: [
                  Text('SR ${match.pricePerPerson.toStringAsFixed(0)} / person',
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(width: 16),
                  const Iconify(Ph.clock,
                      color: AppColors.lightMuted, size: 14),
                  const SizedBox(width: 4),
                  const Text('30 min',
                      style: TextStyle(
                          color: AppColors.lightMuted, fontSize: 12)),
                  const Spacer(),
                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkSlate,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Book now',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}