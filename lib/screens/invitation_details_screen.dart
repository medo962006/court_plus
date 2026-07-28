import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class InvitationDetailsScreen extends StatelessWidget {
  const InvitationDetailsScreen({super.key});

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
        title: const Text('Invitation Details',
            style: TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52, height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.lightField,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person, color: AppColors.lightMuted, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Hafezs', style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('@Hafezs', style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB800).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Pending', style: TextStyle(color: Color(0xFFFFB800), fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Court image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset('assets/images/court1.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            // Match details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  _detailRow(Ph.tennis_ball, 'Court', 'Tennis Outdoor Court A'),
                  const Divider(height: 20),
                  _detailRow(Ph.calendar_blank, 'Date', '15 April 2024'),
                  const Divider(height: 20),
                  _detailRow(Ph.clock, 'Time', '07:00 - 08:00'),
                  const Divider(height: 20),
                  _detailRow(Ph.map_pin, 'Location', 'Eagle Sport Center'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Message
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.lightField,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('Hey! Want to play some tennis this weekend? I booked court A, need one more player.',
                  style: TextStyle(color: AppColors.lightText, fontSize: 13, height: 1.5)),
            ),
            const SizedBox(height: 24),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      side: const BorderSide(color: AppColors.lightBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Decline', style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // If unpaid → go to payment, if paid → go to ticket
                      Navigator.of(context).pushNamed(Routes.paymentGateway);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lightText,
                      minimumSize: const Size.fromHeight(54),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Accept', style: TextStyle(color: AppColors.neonGreen, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pushNamed(Routes.bookingTicket),
                child: const Text('View Booking Ticket', style: TextStyle(color: AppColors.lightMuted, fontSize: 13)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String icon, String label, String value) {
    return Row(
      children: [
        Iconify(icon, size: 18, color: AppColors.lightMuted),
        const SizedBox(width: 10),
        Text('$label:', style: const TextStyle(color: AppColors.lightMuted, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(color: AppColors.lightText, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}