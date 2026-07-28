import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class BookingSuccessScreen extends StatefulWidget {
  const BookingSuccessScreen({super.key});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        leading: const SizedBox.shrink(),
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            color: AppColors.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // ── Animated checkmark ──
                  AnimatedBuilder(
                    animation: _scaleAnim,
                    builder: (context, child) => Transform.scale(
                      scale: _scaleAnim.value,
                      child: child,
                    ),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Iconify(
                        Ph.check,
                        size: 52,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Title ──
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) => Opacity(
                      opacity: _fadeAnim.value,
                      child: child,
                    ),
                    child: const Text(
                      'Booking Successful!',
                      style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) => Opacity(
                      opacity: _fadeAnim.value,
                      child: child,
                    ),
                    child: const Text(
                      'Your court has been reserved successfully.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.lightMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // ── Booking details card ──
                  AnimatedBuilder(
                    animation: _fadeAnim,
                    builder: (context, child) => Opacity(
                      opacity: _fadeAnim.value,
                      child: child,
                    ),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Booking Details',
                            style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _detailRow(
                              Ph.tennis_ball, 'Court', 'Grand Slam Court'),
                          const SizedBox(height: 12),
                          _detailRow(Ph.calendar, 'Date', 'Sat, 15 Nov 2025'),
                          const SizedBox(height: 12),
                          _detailRow(
                              Ph.clock, 'Time', '10:00 - 11:00 AM'),
                          const SizedBox(height: 12),
                          _detailRow(
                              Ph.identification_card, 'Booking ID', '#BK-2025-0042'),
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.lightBorder, height: 1),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text(
                                'Amount Paid',
                                style: TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'SR 185',
                                style: TextStyle(
                                  color: AppColors.lightText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // ── Bottom buttons ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.lightBg,
              border: Border(
                  top: BorderSide(color: AppColors.lightBorder, width: 0.5)),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(Routes.bookingTicket),
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
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Iconify(Ph.ticket, size: 20),
                        SizedBox(width: 8),
                        Text('View Ticket'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(Routes.home, (_) => false),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.lightText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppTheme.fontFamily,
                      ),
                    ),
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String icon, String label, String value) {
    return Row(
      children: [
        Iconify(icon, color: AppColors.lightMuted, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.lightMuted,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.lightText,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}