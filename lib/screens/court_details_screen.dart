import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/courts_provider.dart';
import '../presentation/providers/social_provider.dart';
import '../presentation/providers/supabase_provider.dart';
import '../core/widgets/bouncing_button.dart';
import '../services/models.dart';

class CourtDetailsScreen extends ConsumerStatefulWidget {
  const CourtDetailsScreen({super.key});

  @override
  ConsumerState<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends ConsumerState<CourtDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
    Court? _court;
    bool _isFavorited = false;

    @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
    Widget build(BuildContext context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      final String courtId;
      if (args is String) {
        courtId = args;
      } else if (args is Map) {
        courtId = ((args['id'] ?? args['court_id'] ?? '') as dynamic).toString();
      } else {
        courtId = '';
      }
      final courtsAsync = ref.watch(courtsProvider);

    return courtsAsync.when(
      data: (courts) {
        _court = courts.firstWhere((c) => c.id == courtId, orElse: () => courts.first);
        return _buildScreen(_court!);
      },
      loading: () => Scaffold(
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
            'Court Details',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
                      BouncingButton(
                        scaleAmount: 0.92,
                        onPressed: (_court != null && ref.read(supabaseServiceProvider).currentUser != null)
                            ? () async {
                                final userId = ref.read(supabaseServiceProvider).currentUser!.id;
                                await ref.read(favoriteNotifierProvider(userId).notifier).toggle(_court!.id);
                                setState(() => _isFavorited = !_isFavorited);
                              }
                            : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Iconify(_isFavorited ? Ph.heart_fill : Ph.heart, size: 22),
                        ),
                      ),
            IconButton(icon: const Iconify(Ph.dots_three_bold, size: 22), onPressed: () {}),
          ],
        ),
        body: const Center(child: CircularProgressIndicator(color: AppColors.neonGreen)),
      ),
      error: (e, _) => Scaffold(
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
            'Court Details',
            style: TextStyle(
              color: AppColors.lightText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Iconify(Ph.warning_circle, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text('Failed to load court', style: TextStyle(color: AppColors.lightText, fontSize: 16)),
              const SizedBox(height: 8),
              Text(e.toString(), style: TextStyle(color: AppColors.lightMuted, fontSize: 13), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(Court court) {
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
          'Court Details',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
                    BouncingButton(
                      scaleAmount: 0.92,
                      onPressed: (_court != null && ref.read(supabaseServiceProvider).currentUser != null)
                          ? () async {
                              final userId = ref.read(supabaseServiceProvider).currentUser!.id;
                              await ref.read(favoriteNotifierProvider(userId).notifier).toggle(_court!.id);
                              setState(() => _isFavorited = !_isFavorited);
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Iconify(_isFavorited ? Ph.heart_fill : Ph.heart, size: 22),
                      ),
                    ),
          IconButton(icon: const Iconify(Ph.dots_three_bold, size: 22), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // ── Headline info ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  court.name,
                  style: const TextStyle(
                    color: AppColors.lightText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  court.center,
                  style: const TextStyle(
                    color: AppColors.lightMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Iconify(
                      Ph.star_fill,
                      size: 16,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${court.rating}',
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pushNamed(Routes.reviews),
                      child: Text(
                        '${court.reviewsCount} reviews',
                        style: const TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 13,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Iconify(
                      Ph.heart_fill,
                      size: 16,
                      color: AppColors.error,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${court.likesCount}',
                      style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        court.sportType,
                        style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightField,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Iconify(
                        Ph.map_pin,
                        size: 14,
                        color: AppColors.lightMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        court.location,
                        style: const TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // ── Tab bar ──
          TabBar(
            controller: _tabController,
            labelColor: AppColors.lightText,
            unselectedLabelColor: AppColors.lightMuted,
            indicatorColor: AppColors.neonGreen,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Availability'),
              Tab(text: 'Specs'),
              Tab(text: 'Moments'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _DetailsTab(court: court),
                _AvailabilityTab(court: court),
                _SpecsTab(court: court),
                _MomentsTab(court: court),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Tab 1: Details ───────────────────
class _DetailsTab extends StatelessWidget {
  final Court court;
  const _DetailsTab({required this.court});

  static const _heroImages = [
    'assets/images/court1.jpg',
    'assets/images/court2.jpg',
    'assets/images/banner1.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Hero carousel
        SizedBox(
          height: 200,
          child: PageView(
            children: List.generate(
              3,
                            (i) {
                              final widget = Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: i == 0
                                      ? Hero(
                                          tag: 'court-${court.name.replaceAll(' ', '-')}',
                                          child: Image.asset(_heroImages[i], fit: BoxFit.cover),
                                        )
                                      : Image.asset(_heroImages[i], fit: BoxFit.cover),
                                ),
                              );
                              return widget;
                            },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            3,
            (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == 0 ? 18 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: i == 0 ? AppColors.neonGreen : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Quick stats grid
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Ph.money,
                label: 'Rate per hour',
                value: 'SR ${court.pricePerHour.toStringAsFixed(0)}',
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: _StatCard(
                icon: Ph.timer,
                label: 'Min time',
                value: '30 mins',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Ph.chart_bar,
                label: 'Sessions',
                value: '${court.likesCount + court.reviewsCount}',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
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

// ─────────────────── Tab 2: Availability ───────────────────
class _AvailabilityTab extends ConsumerStatefulWidget {
  final Court court;
  const _AvailabilityTab({required this.court});

  @override
  ConsumerState<_AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends ConsumerState<_AvailabilityTab> {
  // Show April 2024 per requirements
  static const int _year = 2024;
  static const int _month = 4;

  int? _selectedDay;
  String? _selectedTimeSlot;
  Map<int, bool> _availableDays = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    // Load from Supabase - for now use mock availability pattern
    _availableDays = {
      1: true, 2: true, 3: true, 4: true, 5: true, 6: true, 7: true,
      8: true, 9: true, 10: true, 11: true, 12: true, 13: true, 14: true,
      15: true, 16: true, 17: true, 18: true, 19: true, 20: true,
      21: true, 22: true, 23: true, 24: true, 25: true, 26: true,
      27: true, 28: true, 29: true, 30: true,
    };
    _loaded = true;
  }

  DateTime get _selectedDate {
    return DateTime(_year, _month, _selectedDay ?? 1);
  }

  List<String> get _timeSlots {
    if (_selectedDay == null) return [];
    final date = _selectedDate;
    final isWeekend = date.weekday == DateTime.friday || date.weekday == DateTime.saturday;
    if (isWeekend) {
      return ['08:00', '09:00', '10:00', '11:00', '12:00', '13:00', '14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00'];
    }
    return ['14:00', '15:00', '16:00', '17:00', '18:00', '19:00', '20:00', '21:00', '22:00'];
  }

  int get _daysInMonth {
    return DateTime(_year, _month + 1, 0).day;
  }

  int get _firstWeekday {
    return DateTime(_year, _month, 1).weekday % 7;
  }

  Widget _dayCell(int week, int dow) {
    final n = week * 7 + dow - _firstWeekday + 1;
    if (n < 1 || n > _daysInMonth) return const SizedBox(height: 40);
    final available = _availableDays[n] ?? false;
    final selected = _selectedDay == n;
    return GestureDetector(
      onTap: available ? () => setState(() => _selectedDay = n) : null,
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '$n',
            style: TextStyle(
              fontSize: 13,
              fontWeight: available ? FontWeight.w700 : FontWeight.w400,
              color: selected
                  ? Colors.black
                  : available
                      ? const Color(0xFF7CB800)
                      : AppColors.lightMuted.withValues(alpha: 0.5),
            ),
          ),
        ),
              ),
            );
          }

          @override
          Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }

    final slots = _timeSlots;
    final canBook = _selectedDay != null && _selectedTimeSlot != null;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
          children: [
            // ── Calendar ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  // Month / year header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Iconify(Ph.caret_left_bold, size: 18, color: AppColors.lightMuted),
                      Text(
                        'April 2024',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Iconify(Ph.caret_right_bold, size: 18, color: AppColors.lightMuted),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Week day headers
                  Row(
                    children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                        .map(
                          (d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: const TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  // Calendar grid
                  ...List.generate(5, (week) {
                    return Row(
                      children: List.generate(7, (dow) => Expanded(child: _dayCell(week, dow))),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Time slots ──
            if (_selectedDay != null) ...[
              const Text(
                'Available Times',
                style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(slots.length, (i) {
                  final active = _selectedTimeSlot == slots[i];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTimeSlot = slots[i]),
                    child: Container(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: active ? AppColors.neonGreen : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: active ? AppColors.neonGreen : AppColors.lightBorder),
                      ),
                      child: Text(slots[i], textAlign: TextAlign.center, style: TextStyle(
                        color: active ? AppColors.darkText : AppColors.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                    ),
                  );
                }),
              ),
            ],
          ],
        ),
        // ── Bottom button ──
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: canBook
                    ? () {
                        Navigator.of(context).pushNamed(
                          Routes.bookingStep1,
                          arguments: widget.court.id,
                        );
                      }
                    : null,
                child: const Text('Next'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────── Tab 3: Specs ───────────────────
class _SpecsTab extends StatelessWidget {
  final Court court;
  const _SpecsTab({required this.court});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        _SpecSection(
          title: 'Surface & Dimensions',
          children: [
            _SpecRow(Ph.map_pin, 'Surface', court.sportType),
            _SpecRow(Ph.map_pin, 'Indoor/Outdoor', 'Outdoor'),
          ],
        ),
        _SpecSection(
          title: 'Lighting & Amenities',
          children: [
            _SpecRow(Ph.lightbulb, 'LED Floodlights', 'Yes'),
            _SpecRow(Ph.dribbble_logo_fill, 'Ball Machine', 'No'),
            _SpecRow(Ph.waves, 'Water Station', 'Yes'),
          ],
        ),
        _SpecSection(
          title: 'Booking Rules',
          children: [
            _SpecRow(Ph.timer, 'Min Duration', '30 minutes'),
            _SpecRow(Ph.timer, 'Max Duration', '3 hours'),
            _SpecRow(Ph.credit_card, 'Deposit', 'SR 50'),
          ],
        ),
      ],
    );
  }
}

class _SpecSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SpecSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            children: children.map((c) => Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.lightBorder.withValues(alpha: 0.5)),
                ),
              ),
              child: c,
            )).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SpecRow extends StatelessWidget {
  final String icon, label, value;
  const _SpecRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Iconify(icon, size: 20, color: AppColors.neonGreen),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.lightMuted, fontSize: 14))),
          Text(value, style: const TextStyle(color: AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────── Tab 4: Moments ───────────────────
class _MomentsTab extends StatelessWidget {
  final Court court;
  const _MomentsTab({required this.court});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Iconify(Ph.image, size: 48, color: AppColors.lightMuted),
          const SizedBox(height: 16),
          const Text('No moments yet', style: TextStyle(color: AppColors.lightMuted, fontSize: 16)),
          const SizedBox(height: 8),
          const Text('Be the first to share a moment!', style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
        ],
      ),
    );
  }
}