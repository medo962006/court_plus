import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class BookingTicketScreen extends StatefulWidget {
  const BookingTicketScreen({super.key});

  @override
  State<BookingTicketScreen> createState() => _BookingTicketScreenState();
}

class _BookingTicketScreenState extends State<BookingTicketScreen> {
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
        title: const Text('Booking Ticket',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Iconify(Ph.share_fill, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Share functionality coming soon'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          children: [
            // ── Ticket card ──
            _TicketCard(),
            const SizedBox(height: 20),
            // ── Add to Calendar button ──
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Added to calendar'),
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Iconify(Ph.calendar_plus, size: 20),
                label: const Text('Add to Calendar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.darkText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppTheme.fontFamily,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Top: branding strip ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: const BoxDecoration(
              color: AppColors.darkSlate,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Iconify(Ph.tennis_ball_fill,
                      size: 16, color: AppColors.darkSlate),
                ),
                const SizedBox(width: 10),
                const Text('court+',
                    style: TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1)),
              ],
            ),
          ),

          // ── Main content ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // QR code placeholder
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.lightField,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'QR',
                      style: TextStyle(
                        color: AppColors.lightMuted,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Booking ID
                Center(
                  child: Text('#BK-2026-0842',
                      style: const TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 13,
                          letterSpacing: 1)),
                ),
                const SizedBox(height: 20),

                // Info rows
                _InfoRow(
                  icon: Ph.tennis_ball,
                  label: 'Court',
                  value: 'Court A — Eagle Sport',
                ),
                const Divider(height: 20, color: AppColors.lightBorder),
                _InfoRow(
                  icon: Ph.calendar_blank,
                  label: 'Date',
                  value: 'Monday, July 28, 2026',
                ),
                const Divider(height: 20, color: AppColors.lightBorder),
                _InfoRow(
                  icon: Ph.clock,
                  label: 'Time',
                  value: '10:00 AM — 11:30 AM',
                ),
                const Divider(height: 20, color: AppColors.lightBorder),
                _InfoRow(
                  icon: Ph.map_pin,
                  label: 'Location',
                  value: 'Prince Turki St, Riyadh 12345',
                ),
                const Divider(height: 20, color: AppColors.lightBorder),
                _InfoRow(
                  icon: Ph.user_circle,
                  label: 'Player',
                  value: 'Ahmed Al-Saud',
                ),
                const Divider(height: 20, color: AppColors.lightBorder),

                // Amount & Status row
                Row(
                  children: [
                    const Iconify(Ph.wallet, size: 18, color: AppColors.lightMuted),
                    const SizedBox(width: 8),
                    const Text('Amount Paid',
                        style: TextStyle(
                            color: AppColors.lightMuted, fontSize: 13)),
                    const Spacer(),
                    const Text('SR 185',
                        style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 14),

                // Status badge
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F8E8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Iconify(Ph.check_circle_fill,
                            size: 16, color: Color(0xFF2E7D32)),
                        SizedBox(width: 6),
                        Text('Confirmed',
                            style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ── Perforated dashed edge ──
          CustomPaint(
            size: const Size(double.infinity, 16),
            painter: _PerforationPainter(),
          ),

          // ── Bottom tear-off stub ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: AppColors.lightSurface,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StubLabel('Booking ID', '#BK-2026-0842'),
                    _StubLabel('Court', 'A'),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StubLabel('Date', 'Jul 28'),
                    _StubLabel('Time', '10:00 AM'),
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

class _InfoRow extends StatelessWidget {
  final String icon, label, value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Iconify(icon, size: 18, color: AppColors.lightMuted),
          const SizedBox(width: 10),
          SizedBox(
            width: 58,
            child: Text(label,
                style: const TextStyle(
                    color: AppColors.lightMuted, fontSize: 13)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.lightText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _StubLabel extends StatelessWidget {
  final String label, value;

  const _StubLabel(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: AppColors.lightMuted, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                color: AppColors.lightText,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Paints a perforation (dashed) line separating ticket body from stub.
class _PerforationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.lightBorder
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashW = 8.0;
    const gapW = 6.0;
    final half = size.height / 2;

    double x = 20;
    while (x < size.width - 20) {
      canvas.drawLine(Offset(x, half), Offset(x + dashW, half), paint);
      x += dashW + gapW;
    }

    // Perforation dots at ends
    final dotPaint = Paint()
      ..color = AppColors.lightBorder
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(16, half), 3, dotPaint);
    canvas.drawCircle(Offset(size.width - 16, half), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}