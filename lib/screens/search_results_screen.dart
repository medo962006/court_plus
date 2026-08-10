import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../services/models.dart';
import '../presentation/providers/courts_provider.dart';

class SearchResultsScreen extends ConsumerStatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  ConsumerState<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends ConsumerState<SearchResultsScreen> {
  int _navIndex = 1;
  int _tabIndex = 0;
  int _chipIndex = 0;

  static const _tabs = ['Courts', 'Coaches'];
  static const _chips = ['All courts', 'Tennis', 'Football'];

  @override
  Widget build(BuildContext context) {
    final courtsAsync = ref.watch(courtsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22, color: AppColors.lightText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Explore',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Iconify(Ph.bell, size: 22, color: AppColors.lightText),
                onPressed: () => Navigator.of(context).pushNamed(Routes.notifications),
              ),
              Positioned(
                right: 10, top: 8,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
                  Text('Search courts...',
                      style: TextStyle(color: AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_tabs.length, (i) {
                final active = i == _tabIndex;
                return GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(
                        color: active ? AppColors.neonGreen : Colors.transparent,
                        width: 2.5,
                      )),
                    ),
                    child: Text(_tabs[i], style: TextStyle(
                      color: active ? AppColors.lightText : AppColors.lightMuted,
                      fontSize: 15,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    )),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: List.generate(_chips.length, (i) {
                final active = i == _chipIndex;
                return GestureDetector(
                  onTap: () => setState(() => _chipIndex = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: active ? AppColors.neonGreen : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: active ? AppColors.neonGreen : AppColors.lightBorder),
                    ),
                    child: Text(_chips[i], style: TextStyle(
                      color: active ? AppColors.darkText : AppColors.lightMuted,
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                    )),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // Results count + filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                courtsAsync.when(
                  data: (courts) => Text('${courts.length} results found',
                      style: const TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                  loading: () => const Text('Loading...',
                      style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                  error: (_, _) => const Text('0 results found',
                      style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Iconify(Ph.funnel, size: 18, color: AppColors.lightText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Results list (live data)
          Expanded(
            child: courtsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('$e', style: const TextStyle(color: AppColors.lightMuted)),
                  ],
                ),
              ),
              data: (courts) {
                final filtered = _filterCourts(courts);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No courts found', style: TextStyle(color: AppColors.lightMuted)),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, i) => _SearchResultCard(
                    court: filtered[i],
                    onTap: () => Navigator.of(context).pushNamed(Routes.courtDetails, arguments: filtered[i].id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        index: _navIndex,
        onTap: (i) {
          setState(() => _navIndex = i);
          if (i == 0) Navigator.of(context).pushReplacementNamed(Routes.courts);
          if (i == 2) Navigator.of(context).pushReplacementNamed(Routes.home);
          if (i == 3) Navigator.of(context).pushReplacementNamed(Routes.activity);
          if (i == 4) Navigator.of(context).pushReplacementNamed(Routes.profile);
        },
      ),
    );
  }

  List<Court> _filterCourts(List<Court> courts) {
    final chip = _chips[_chipIndex];
    if (chip == 'All courts') return courts;
    return courts.where((c) => c.sportType == chip).toList();
  }
}

class _SearchResultCard extends StatelessWidget {
  final Court court;
  final VoidCallback onTap;
  const _SearchResultCard({required this.court, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightBorder),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    color: AppColors.lightField,
                    child: const Center(child: Icon(Icons.sports_tennis, size: 48, color: AppColors.lightMuted)),
                  ),
                ),
                Positioned(
                  right: 10, bottom: 10,
                  child: Container(
                    width: 34, height: 34,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                    child: const Center(child: Iconify(Ph.bookmark_simple_fill, size: 18, color: AppColors.lightText)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(court.name, style: const TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Iconify(Ph.star_fill, size: 14, color: Color(0xFFFFB800)),
                      const SizedBox(width: 4),
                      Text('${court.rating}', style: const TextStyle(color: AppColors.lightText, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Iconify(Ph.map_pin, size: 14, color: AppColors.lightMuted),
                      const SizedBox(width: 4),
                      Text(court.center, style: const TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                      const Spacer(),
                      Text(court.distance > 0 ? '${court.distance}km away' : 'Distance unavailable', style: const TextStyle(color: AppColors.lightMuted, fontSize: 12)),
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

class _BottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;
  const _BottomNav({required this.index, required this.onTap});

  static const _items = [
    ('Courts', Ph.tennis_ball),
    ('Explore', Ph.compass),
    ('Home', Ph.house_fill),
    ('Activity', Ph.receipt),
    ('Profile', Ph.user_circle),
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
                  onTap: () => onTap(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        height: 3, width: 28,
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.neonGreen : Colors.transparent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Iconify(_items[i].$2, size: 24,
                          color: active ? const Color(0xFF7CB800) : AppColors.lightMuted),
                      const SizedBox(height: 2),
                      Text(_items[i].$1, style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? AppColors.lightText : AppColors.lightMuted,
                      )),
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