import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../services/models.dart';
import '../services/mock_data_service.dart';

class CourtDetailsScreen extends StatefulWidget {
  const CourtDetailsScreen({super.key});

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Court? _court;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_court == null) {
      final id = ModalRoute.of(context)!.settings.arguments as String;
      _court = MockDataService.getCourtById(id);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_court == null) {
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
            IconButton(
              icon: const Iconify(Ph.heart, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: const Iconify(Ph.dots_three_bold, size: 22),
              onPressed: () {},
            ),
          ],
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.neonGreen),
        ),
      );
    }

    final court = _court!;
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
          IconButton(icon: const Iconify(Ph.heart, size: 22), onPressed: () {}),
          IconButton(
            icon: const Iconify(Ph.dots_three_bold, size: 22),
            onPressed: () {},
          ),
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
                      onTap: () =>
                          Navigator.of(context).pushNamed(Routes.reviews),
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
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(_heroImages[i], fit: BoxFit.cover),
                ),
              ),
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
class _AvailabilityTab extends StatefulWidget {
  final Court court;
  const _AvailabilityTab({required this.court});

  @override
  State<_AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<_AvailabilityTab> {
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
    _availableDays = MockDataService.getAvailableDays(_year, _month);
    _loaded = true;
  }

  DateTime get _selectedDate {
    return DateTime(_year, _month, _selectedDay ?? 1);
  }

  List<String> get _timeSlots {
    if (_selectedDay == null) return [];
    return MockDataService.getTimeSlots(_selectedDate);
  }

  int get _daysInMonth {
    return DateTime(_year, _month + 1, 0).day;
  }

  /// Day of week for the 1st of the month (0 = Sunday, 6 = Saturday).
  int get _firstWeekday {
    return DateTime(_year, _month, 1).weekday % 7;
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
                      Iconify(
                        Ph.caret_left_bold,
                        size: 18,
                        color: AppColors.lightMuted,
                      ),
                      Text(
                        'April 2024',
                        style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Iconify(
                        Ph.caret_right_bold,
                        size: 18,
                        color: AppColors.lightMuted,
                      ),
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
                  // Day cells
                  ...List.generate(_calcWeeks(), (week) {
                    return Row(
                      children: List.generate(
                        7,
                        (dow) => Expanded(child: _dayCell(week, dow)),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Legend
            Row(
              children: [
                _legendDot(AppColors.neonGreen),
                const SizedBox(width: 6),
                const Text(
                  'Available',
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 12),
                ),
                const SizedBox(width: 20),
                _legendDot(Colors.transparent, border: true),
                const SizedBox(width: 6),
                const Text(
                  'Unavailable',
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // ── Time slots ──
            if (_selectedDay != null) ...[
              Row(
                children: [
                  const Iconify(Ph.clock, size: 18, color: AppColors.lightText),
                  const SizedBox(width: 8),
                  Text(
                    'Time slots — April ${_selectedDay!}, $_year',
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (slots.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: const Text(
                    'No slots available for this day.',
                    style: TextStyle(color: AppColors.lightMuted, fontSize: 14),
                  ),
                )
              else
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: slots.map((slot) {
                    final selected = _selectedTimeSlot == slot;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedTimeSlot = slot),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.neonGreen
                              : AppColors.lightField,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.neonGreen
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            color: selected
                                ? Colors.black
                                : AppColors.lightText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 80),
            ] else
              Container(
                padding: const EdgeInsets.symmetric(vertical: 32),
                alignment: Alignment.center,
                child: const Text(
                  'Select a date to see available time slots.',
                  style: TextStyle(color: AppColors.lightMuted, fontSize: 14),
                ),
              ),
          ],
        ),
        // ── Book Now floating button ──
        if (_selectedDay != null)
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: canBook
                    ? () => Navigator.of(context).pushNamed(Routes.bookingStep1)
                    : null,
                icon: const Iconify(
                  Ph.calendar_plus,
                  size: 20,
                  color: Colors.black,
                ),
                label: const Text(
                  'Book Now',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.lightField,
                  disabledForegroundColor: AppColors.lightMuted,
                  elevation: 6,
                  shadowColor: AppColors.neonGreen.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  int _calcWeeks() {
    final totalCells = _firstWeekday + _daysInMonth;
    return (totalCells / 7).ceil();
  }

  Widget _dayCell(int week, int dow) {
    final cellIndex = week * 7 + dow;
    final dayNumber = cellIndex - _firstWeekday + 1;

    if (dayNumber < 1 || dayNumber > _daysInMonth) {
      return const SizedBox(height: 40);
    }

    final available = _availableDays[dayNumber] ?? false;
    final selected = _selectedDay == dayNumber;

    return GestureDetector(
      onTap: available
          ? () => setState(() {
              _selectedDay = dayNumber;
              _selectedTimeSlot = null;
            })
          : null,
      child: Container(
        height: 40,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonGreen : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$dayNumber',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: available ? FontWeight.w700 : FontWeight.w400,
                  color: selected
                      ? Colors.black
                      : available
                      ? AppColors.lightText
                      : AppColors.lightMuted.withValues(alpha: 0.4),
                ),
              ),
              if (available && !selected)
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(top: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.neonGreen,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legendDot(Color color, {bool border = false}) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: border ? Border.all(color: AppColors.lightBorder) : null,
      ),
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
        // Court layout diagram
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(16),
          ),
          child: CustomPaint(painter: _CourtLinesPainter()),
        ),
        const SizedBox(height: 20),
        const _SpecRow(icon: Ph.leaf, label: 'Type', value: 'Grass'),
        const _SpecRow(
          icon: Ph.arrows_horizontal,
          label: 'Width Singles',
          value: '8.23 metres',
        ),
        const _SpecRow(
          icon: Ph.arrows_vertical,
          label: 'Length',
          value: '23.77 metres',
        ),
        const SizedBox(height: 20),
        const Text(
          'Equipment',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _SpecRow(
          icon: Ph.tennis_ball,
          label: 'Balls',
          value: '3 cans included',
        ),
        const _SpecRow(icon: Ph.tennis_ball, label: 'Rackets', value: '2 available'),
        const _SpecRow(icon: Ph.drop, label: 'Water', value: 'Complimentary'),
      ],
    );
  }
}

/// Simple white court line markings over green (diagram only — not a photo).
class _CourtLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final r = Rect.fromLTWH(
      size.width * 0.08,
      size.height * 0.12,
      size.width * 0.84,
      size.height * 0.76,
    );
    canvas.drawRect(r, p);
    // Singles lines
    canvas.drawLine(
      Offset(r.left, r.top + r.height * 0.18),
      Offset(r.right, r.top + r.height * 0.18),
      p,
    );
    canvas.drawLine(
      Offset(r.left, r.bottom - r.height * 0.18),
      Offset(r.right, r.bottom - r.height * 0.18),
      p,
    );
    // Net
    canvas.drawLine(
      Offset(r.center.dx, r.top),
      Offset(r.center.dx, r.bottom),
      p..strokeWidth = 3,
    );
    // Service boxes
    p.strokeWidth = 2;
    canvas.drawLine(
      Offset(r.left + r.width * 0.25, r.top + r.height * 0.18),
      Offset(r.left + r.width * 0.25, r.bottom - r.height * 0.18),
      p,
    );
    canvas.drawLine(
      Offset(r.right - r.width * 0.25, r.top + r.height * 0.18),
      Offset(r.right - r.width * 0.25, r.bottom - r.height * 0.18),
      p,
    );
    canvas.drawLine(
      Offset(r.left + r.width * 0.25, r.center.dy),
      Offset(r.right - r.width * 0.25, r.center.dy),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _SpecRow extends StatelessWidget {
  final String icon, label, value;
  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Iconify(icon, size: 20, color: AppColors.lightText),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.lightMuted, fontSize: 13),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Tab 4: Moments ───────────────────
class _MomentsTab extends StatelessWidget {
  final Court court;
  const _MomentsTab({required this.court});

  static const _moments = [
    ('assets/images/court1.jpg', 21, 'Serving ace at sunset'),
    ('assets/images/court2.jpg', 34, 'Team after finals win'),
    ('assets/images/banner1.jpg', 12, 'Early morning practice'),
    ('assets/images/banner2.jpg', 45, 'Weekend tournament'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _moments.length,
      itemBuilder: (context, i) {
        final m = _moments[i];
        return GestureDetector(
          onTap: () => _showMomentDetail(context, m.$1, m.$3, m.$2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(m.$1, fit: BoxFit.cover),
                Positioned(
                  bottom: 8,
                  right: 10,
                  child: Row(
                    children: [
                      const Iconify(
                        Ph.heart_fill,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${m.$2}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(color: Colors.black54, blurRadius: 4),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMomentDetail(
    BuildContext context,
    String imagePath,
    String caption,
    int likes,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.darkBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Image.asset(imagePath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      caption,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Iconify(
                    Ph.heart_fill,
                    size: 20,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$likes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
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
