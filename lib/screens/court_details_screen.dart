import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class CourtDetailsScreen extends StatefulWidget {
  const CourtDetailsScreen({super.key});

  @override
  State<CourtDetailsScreen> createState() => _CourtDetailsScreenState();
}

class _CourtDetailsScreenState extends State<CourtDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text('Court Details',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
              icon: const Iconify(Ph.heart, size: 22), onPressed: () {}),
          IconButton(
              icon: const Iconify(Ph.dots_three_bold, size: 22),
              onPressed: () {}),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // ── Headline info ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tennis Outdoor Court A',
                        style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Eagle Sport Center',
                        style: TextStyle(
                            color: AppColors.lightMuted, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Iconify(Ph.star_fill,
                            size: 16, color: Color(0xFFFFB800)),
                        const SizedBox(width: 4),
                        const Text('4.0',
                            style: TextStyle(
                                color: AppColors.lightText,
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.of(context)
                              .pushNamed(Routes.reviews),
                          child: const Text('26 reviews',
                              style: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 13,
                                  decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(width: 16),
                        const Iconify(Ph.heart_fill,
                            size: 16, color: AppColors.error),
                        const SizedBox(width: 4),
                        const Text('273',
                            style: TextStyle(
                                color: AppColors.lightText, fontSize: 13)),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen
                                .withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Tennis',
                              style: TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.lightField,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Iconify(Ph.map_pin,
                              size: 14, color: AppColors.lightMuted),
                          SizedBox(width: 6),
                          Text('King Fahd Rd, Al Olaya, Riyadh',
                              style: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 12)),
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
                    fontSize: 13, fontWeight: FontWeight.w700),
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
                  children: const [
                    _DetailsTab(),
                    _AvailabilityTab(),
                    _SpecsTab(),
                    _MomentsTab(),
                  ],
                ),
              ),
            ],
          ),
          // ── Floating book button ──
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Iconify(Ph.calendar_plus,
                    size: 20, color: Colors.black),
                label: const Text('Book This Court',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shadowColor: AppColors.neonGreen.withValues(alpha: 0.4),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────── Tab 1: Details ───────────────────
class _DetailsTab extends StatelessWidget {
  const _DetailsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Hero carousel
        // PLACEHOLDER IMAGES NEEDED:
        // - assets/images/court_hero_1.jpg → wide shot of tennis court
        // - assets/images/court_hero_2.jpg → net close-up
        // - assets/images/court_hero_3.jpg → aerial view of court
        SizedBox(
          height: 200,
          child: PageView(
            children: List.generate(
              3,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset('assets/images/court1.jpg',
                      fit: BoxFit.cover),
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
          children: const [
            Expanded(
                child: _StatCard(
                    icon: Ph.money, label: 'Rate per hour', value: 'SR 100')),
            SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    icon: Ph.timer, label: 'Min time', value: '30 mins')),
            SizedBox(width: 12),
            Expanded(
                child: _StatCard(
                    icon: Ph.chart_bar, label: 'Sessions', value: '258')),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  const _StatCard(
      {required this.icon, required this.label, required this.value});

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
          Text(value,
              style: const TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.lightMuted, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────── Tab 2: Availability ───────────────────
class _AvailabilityTab extends StatefulWidget {
  const _AvailabilityTab();

  @override
  State<_AvailabilityTab> createState() => _AvailabilityTabState();
}

class _AvailabilityTabState extends State<_AvailabilityTab> {
  int? _selectedDay;
  // Demo data: available days in April 2024
  static const _available = {2, 5, 8, 11, 14, 17, 20, 23, 26, 29};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Iconify(Ph.caret_left_bold,
                      size: 18, color: AppColors.lightMuted),
                  Text('April 2024',
                      style: TextStyle(
                          color: AppColors.lightText,
                          fontSize: 15,
                          fontWeight: FontWeight.w700)),
                  Iconify(Ph.caret_right_bold,
                      size: 18, color: AppColors.lightMuted),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                    .map((d) => Expanded(
                        child: Center(
                            child: Text(d,
                                style: const TextStyle(
                                    color: AppColors.lightMuted,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)))))
                    .toList(),
              ),
              const SizedBox(height: 8),
              // April 2024 starts Monday (Sunday-first grid → offset 1)
              ...List.generate(5, (week) {
                return Row(
                  children: List.generate(
                      7, (dow) => Expanded(child: _dayCell(week, dow))),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Row(
          children: [
            _legendDot(AppColors.lightField, border: true),
            const SizedBox(width: 6),
            const Text('Fully booked',
                style:
                    TextStyle(color: AppColors.lightMuted, fontSize: 12)),
            const SizedBox(width: 20),
            _legendDot(AppColors.neonGreen),
            const SizedBox(width: 6),
            const Text('Available',
                style:
                    TextStyle(color: AppColors.lightMuted, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _dayCell(int week, int dow) {
    // Sunday-first grid; April 1, 2024 is Monday → day number = cell index
    final n = week * 7 + dow;
    if (n < 1 || n > 30) {
      return const SizedBox(height: 40);
    }
    final available = _available.contains(n);
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

  Widget _legendDot(Color color, {bool border = false}) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border:
            border ? Border.all(color: AppColors.lightBorder) : null,
      ),
    );
  }
}

// ─────────────────── Tab 3: Specs ───────────────────
class _SpecsTab extends StatelessWidget {
  const _SpecsTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      children: [
        // Court layout diagram
        // PLACEHOLDER IMAGE NEEDED:
        // - assets/images/court_diagram.png → top-down tennis court diagram,
        //   green background with white line markings
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
            value: '8.23 metres'),
        const _SpecRow(
            icon: Ph.arrows_vertical,
            label: 'Length',
            value: '23.77 metres'),
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
    final r = Rect.fromLTWH(size.width * 0.08, size.height * 0.12,
        size.width * 0.84, size.height * 0.76);
    canvas.drawRect(r, p);
    // Singles lines
    canvas.drawLine(Offset(r.left, r.top + r.height * 0.18),
        Offset(r.right, r.top + r.height * 0.18), p);
    canvas.drawLine(Offset(r.left, r.bottom - r.height * 0.18),
        Offset(r.right, r.bottom - r.height * 0.18), p);
    // Net
    canvas.drawLine(Offset(r.center.dx, r.top), Offset(r.center.dx, r.bottom),
        p..strokeWidth = 3);
    // Service boxes
    p.strokeWidth = 2;
    canvas.drawLine(Offset(r.left + r.width * 0.25, r.top + r.height * 0.18),
        Offset(r.left + r.width * 0.25, r.bottom - r.height * 0.18), p);
    canvas.drawLine(Offset(r.right - r.width * 0.25, r.top + r.height * 0.18),
        Offset(r.right - r.width * 0.25, r.bottom - r.height * 0.18), p);
    canvas.drawLine(
        Offset(r.left + r.width * 0.25, r.center.dy),
        Offset(r.right - r.width * 0.25, r.center.dy),
        p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _SpecRow extends StatelessWidget {
  final String icon, label, value;
  const _SpecRow(
      {required this.icon, required this.label, required this.value});

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
          Text(label,
              style: const TextStyle(
                  color: AppColors.lightMuted, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.lightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

// ─────────────────── Tab 4: Moments ───────────────────
class _MomentsTab extends StatelessWidget {
  const _MomentsTab();

  // PLACEHOLDER IMAGES NEEDED:
  // - assets/images/moment_1.jpg → player selfie on court
  // - assets/images/moment_2.jpg → group photo after match
  // - assets/images/moment_3.jpg → action shot rally
  // - assets/images/moment_4.jpg → court at sunset
  static const _moments = [
    ('assets/images/court1.jpg', 21),
    ('assets/images/court2.jpg', 34),
    ('assets/images/banner1.jpg', 12),
    ('assets/images/banner2.jpg', 45),
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
        return ClipRRect(
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
                    const Iconify(Ph.heart_fill,
                        size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text('${m.$2}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(color: Colors.black54, blurRadius: 4)
                            ])),
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