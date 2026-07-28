import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        title: const Text('Activity',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Iconify(Ph.list_bold, size: 22),
            onPressed: () => Navigator.of(context).pushNamed(Routes.activityLog),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.lightText,
          unselectedLabelColor: AppColors.lightMuted,
          indicatorColor: AppColors.neonGreen,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Before Match'),
            Tab(text: 'During Match'),
            Tab(text: 'After Match'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_beforeMatches),
          _buildList(_duringMatches),
          _buildList(_afterMatches),
        ],
      ),
    );
  }

  static const _statuses = {
    'before': ('Upcoming', Color(0xFFFFB800), Ph.hourglass_medium),
    'during': ('Live Now', Color(0xFF00C853), Ph.circle_fill),
    'after': ('Completed', AppColors.lightMuted, Ph.check_circle),
  };

  static const _beforeMatches = [
    ('assets/images/court1.jpg', 'Tennis Outdoor A', 'Eagle Sport', '15 Apr 2024', '07:00', 'before'),
    ('assets/images/court2.jpg', 'Pro Tennis Arena', 'Al Malaz Club', '17 Apr 2024', '09:00', 'before'),
  ];

  static const _duringMatches = [
    ('assets/images/court1.jpg', 'Tennis Outdoor A', 'Eagle Sport', '15 Apr 2024', '07:00', 'during'),
  ];

  static const _afterMatches = [
    ('assets/images/court2.jpg', 'Pro Tennis Arena', 'Al Malaz Club', '10 Apr 2024', '08:00', 'after'),
    ('assets/images/banner1.jpg', 'Football Pitch 1', 'Al Malaz Club', '5 Apr 2024', '18:00', 'after'),
  ];

  Widget _buildList(List matches) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      itemCount: matches.length,
      itemBuilder: (context, i) {
        final m = matches[i];
        final status = _statuses[m.$5]!;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.asset(m.$1, height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.$2, style: const TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text('${m.$3} · ${m.$4} ${m.$5}', style: const TextStyle(color: AppColors.lightMuted, fontSize: 12)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: status.$2.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Iconify(status.$3, size: 12, color: status.$2),
                          const SizedBox(width: 4),
                          Text(status.$1, style: TextStyle(color: status.$2, fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}