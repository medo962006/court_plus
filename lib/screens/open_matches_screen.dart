import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class OpenMatchesScreen extends StatefulWidget {
  const OpenMatchesScreen({super.key});

  @override
  State<OpenMatchesScreen> createState() => _OpenMatchesScreenState();
}

class _OpenMatchesScreenState extends State<OpenMatchesScreen> {
  static const _matches = [
    _MatchData(
      courtName: 'Court A - Tennis',
      dateTime: 'Today, 18:00',
      level: 'Intermediate',
      gender: 'Mixed',
      spots: 2,
      price: 25.0,
      courtInitials: 'A',
    ),
    _MatchData(
      courtName: 'Court B - Padel',
      dateTime: 'Tomorrow, 20:00',
      level: 'Advanced',
      gender: 'Male',
      spots: 1,
      price: 18.0,
      courtInitials: 'B',
    ),
    _MatchData(
      courtName: 'Court C - Tennis',
      dateTime: 'Fri, 16:30',
      level: 'Beginner',
      gender: 'Mixed',
      spots: 3,
      price: 15.0,
      courtInitials: 'C',
    ),
    _MatchData(
      courtName: 'Court D - Tennis',
      dateTime: 'Sat, 09:00',
      level: 'Advanced',
      gender: 'Female',
      spots: 1,
      price: 20.0,
      courtInitials: 'D',
    ),
    _MatchData(
      courtName: 'Court E - Padel',
      dateTime: 'Sat, 14:00',
      level: 'Intermediate',
      gender: 'Mixed',
      spots: 2,
      price: 22.0,
      courtInitials: 'E',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Open Matches',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          // ── Header with filter / sort ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            color: AppColors.lightBg,
            child: Row(
              children: [
                // Filter button
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed(Routes.matchFilter),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.lightField,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Iconify(Ph.funnel, size: 16,
                              color: AppColors.lightText),
                          SizedBox(width: 6),
                          Text('Filter',
                              style: TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Sort button
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.lightField,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Iconify(Ph.arrows_down_up, size: 16,
                          color: AppColors.lightText),
                      SizedBox(width: 6),
                      Text('Sort',
                          style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Match cards list ──
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
              itemCount: _matches.length,
              itemBuilder: (context, index) => _MatchCard(
                data: _matches[index],
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
      // ── Create Match FAB ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(Routes.startMatch),
        backgroundColor: AppColors.neonGreen,
        foregroundColor: AppColors.darkText,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        icon: const Iconify(Ph.plus, size: 20),
        label: const Text('Create Match',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

// ── Data class ──
class _MatchData {
  final String courtName, dateTime, level, gender, courtInitials;
  final int spots;
  final double price;

  const _MatchData({
    required this.courtName,
    required this.dateTime,
    required this.level,
    required this.gender,
    required this.spots,
    required this.price,
    required this.courtInitials,
  });
}

// ── Match card ──
class _MatchCard extends StatelessWidget {
  final _MatchData data;
  final VoidCallback onTap;

  const _MatchCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Court image placeholder ──
              Container(
                height: 130,
                width: double.infinity,
                color: AppColors.lightField,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Iconify(Ph.tennis_ball,
                          color: AppColors.lightMuted, size: 32),
                      const SizedBox(height: 6),
                      Text('Court ${data.courtInitials}',
                          style: const TextStyle(
                              color: AppColors.lightMuted,
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),

              // ── Details ──
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(data.courtName,
                        style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 15,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),

                    // Date/time
                    Row(
                      children: [
                        const Iconify(Ph.clock,
                            color: AppColors.lightMuted, size: 15),
                        const SizedBox(width: 5),
                        Text(data.dateTime,
                            style: const TextStyle(
                                color: AppColors.lightMuted,
                                fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Badges row + spots + price
                    Row(
                      children: [
                        // Level badge
                        _badge(
                          data.level,
                          data.level == 'Beginner'
                              ? AppColors.neonGreen
                              : data.level == 'Intermediate'
                                  ? const Color(0xFFFFB800)
                                  : const Color(0xFFFF4D4F),
                        ),
                        const SizedBox(width: 6),
                        // Gender badge
                        _badge(
                          data.gender,
                          data.gender == 'Mixed'
                              ? const Color(0xFF7C5CFC)
                              : const Color(0xFF3B82F6),
                        ),
                        const Spacer(),
                        // Spots
                        Iconify(Ph.users,
                            color: data.spots > 0
                                ? AppColors.lightText
                                : AppColors.lightMuted,
                            size: 14),
                        const SizedBox(width: 4),
                        Text('${data.spots} spots',
                            style: TextStyle(
                                color: data.spots > 0
                                    ? AppColors.lightText
                                    : AppColors.lightMuted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 12),
                        // Price
                        Text('\$${data.price.toStringAsFixed(0)}/person',
                            style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(80), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}