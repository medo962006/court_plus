import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class BookingStep4Screen extends StatelessWidget {
  const BookingStep4Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Review Booking',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Booking summary card ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkField,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Booking Summary',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _summaryRow(Ph.calendar, 'Date', 'Sat, 15 Nov 2025'),
                        const SizedBox(height: 14),
                        _summaryRow(Ph.clock, 'Time', '10:00 - 11:00 AM'),
                        const SizedBox(height: 14),
                        _summaryRow(Ph.hourglass, 'Duration', '1 hour'),
                        const SizedBox(height: 14),
                        _summaryRow(Ph.tennis_ball, 'Court', 'Grand Slam Court'),
                        const SizedBox(height: 14),
                        _summaryRow(Ph.map_pin, 'Location', 'Riyadh Sports Center'),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.darkBorder, height: 1),
                        const SizedBox(height: 16),
                        // ── Extras ──
                        const Text(
                          'Extras',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _extrasChip('Racket Rental', 'SR 25'),
                        const SizedBox(height: 8),
                        _extrasChip('Bottled Water (x2)', 'SR 10'),
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.darkBorder, height: 1),
                        const SizedBox(height: 16),
                        // ── Total ──
                        Row(
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'SR 185',
                              style: TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // ── Booking policy note ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkField,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Iconify(Ph.info,
                            color: AppColors.neonGreen, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Free cancellation up to 24 hours before your booking.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── Bottom button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.darkBg,
              border: Border(
                  top: BorderSide(color: AppColors.darkBorder, width: 0.5)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.paymentGateway),
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
                    Iconify(Ph.credit_card, size: 20),
                    SizedBox(width: 8),
                    Text('Proceed to Pay'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String icon, String label, String value) {
    return Row(
      children: [
        Iconify(icon,
            color: AppColors.neonGreen, size: 18),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _extrasChip(String label, String price) {
    return Row(
      children: [
        Iconify(Ph.check_circle,
            color: AppColors.neonGreen.withValues(alpha: 0.7), size: 16),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Text(
          price,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}