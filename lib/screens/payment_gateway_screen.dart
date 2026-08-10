import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/providers.dart';

/// Payment gateway screen.
/// NOTE: Real Stripe integration is coming soon. Currently simulates payment
/// for flow testing against the lock_booking_slot RPC.
class PaymentGatewayScreen extends ConsumerStatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  ConsumerState<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends ConsumerState<PaymentGatewayScreen> {
  int _selectedMethod = 0;
  bool _isProcessing = false;

  static const _methods = <_PaymentMethod>[
    _PaymentMethod(Ph.apple_logo, 'Apple Pay'),
    _PaymentMethod(Ph.google_logo, 'Google Pay'),
    _PaymentMethod(Ph.credit_card, 'Credit Card'),
    _PaymentMethod(Ph.device_mobile, 'STC Pay'),
  ];

  Future<void> _processPayment() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final bookingState = ref.read(bookingStateProvider);
      final court = bookingState.court;
      if (court == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No booking found. Please start over.'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      // Booking was already created in Step4 via lockBookingSlot RPC.
      // Here we simulate payment confirmation. Real Stripe integration will
      // call PaymentService.confirmPayment() and the confirm_booking_payment RPC.
      await ref.read(supabaseServiceProvider).processPayment(
        amount: bookingState.totalAmount,
        method: _methods[_selectedMethod].label,
        bookingId: bookingState.bookingId ?? bookingState.court?.id,
      );

      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.bookingSuccess,
          (route) => route.settings.name == Routes.home,
          arguments: {
            'bookingId': bookingState.bookingId,
            'courtName': court.name,
            'date': bookingState.selectedDate?.toIso8601String() ?? '',
            'timeSlot': bookingState.selectedTimeSlot ?? '',
            'duration': bookingState.duration,
            'totalAmount': bookingState.totalAmount,
            'paymentMethod': _methods[_selectedMethod].label,
          },
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final courtFee = (args?['courtFee'] as num?)?.toDouble() ?? 0;
    final addonsSubtotal = (args?['addonsSubtotal'] as num?)?.toInt() ?? 0;
    final total = courtFee + addonsSubtotal;

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, color: AppColors.lightText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Payment', style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w600)),
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
                  // Order summary card
                  Container(
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
                        const Text('Order Summary', style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        _summaryRow('Court Fee', 'SR ${courtFee.toInt()}'),
                        const SizedBox(height: 10),
                        _summaryRow('Add-ons', 'SR $addonsSubtotal'),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.lightBorder, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('Total', style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.bold)),
                            const Spacer(),
                            Text('SR ${total.toInt()}', style: const TextStyle(color: AppColors.lightText, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment method
                  const Text('Select Payment Method', style: TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 14),
                  ...List.generate(_methods.length, (i) {
                    final method = _methods[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMethod = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: i == _selectedMethod ? AppColors.neonGreen.withValues(alpha: 0.08) : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: i == _selectedMethod ? AppColors.neonGreen : AppColors.lightBorder,
                              width: i == _selectedMethod ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Iconify(method.icon, size: 26, color: i == _selectedMethod ? AppColors.lightText : AppColors.lightMuted),
                              const SizedBox(width: 14),
                              Expanded(child: Text(method.label, style: TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: i == _selectedMethod ? FontWeight.w600 : FontWeight.w500))),
                              Container(
                                width: 22, height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: i == _selectedMethod ? AppColors.neonGreen : AppColors.lightBorder, width: i == _selectedMethod ? 2 : 1.5),
                                  color: i == _selectedMethod ? AppColors.neonGreen : Colors.transparent,
                                ),
                                child: i == _selectedMethod ? const Icon(Icons.check, size: 14, color: AppColors.darkText) : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),

                  // 🚧 Stripe integration notice
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB74D), width: 1),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Iconify(Ph.info, color: Color(0xFFE65100), size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Stripe payment integration is coming soon. Your booking '
                            'will be recorded and payment will be processed when the gateway goes live.',
                            style: TextStyle(
                              color: Color(0xFFBF360C),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                  // Secure notice
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(Ph.lock, color: AppColors.lightMuted, size: 14),
                      const SizedBox(width: 6),
                      const Text('Secure payment via SSL encryption', style: TextStyle(color: AppColors.lightMuted, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Pay button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.lightBg,
              border: Border(top: BorderSide(color: AppColors.lightBorder, width: 0.5)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.darkText,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: AppTheme.fontFamily),
                ),
                child: _isProcessing
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.darkText))
                    : Text('Pay SR ${total.toInt()}'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(color: AppColors.lightMuted, fontSize: 14))),
        Text(value, style: const TextStyle(color: AppColors.lightText, fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _PaymentMethod {
  final String icon;
  final String label;
  const _PaymentMethod(this.icon, this.label);
}