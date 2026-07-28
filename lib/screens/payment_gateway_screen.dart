import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class PaymentGatewayScreen extends StatefulWidget {
  const PaymentGatewayScreen({super.key});

  @override
  State<PaymentGatewayScreen> createState() => _PaymentGatewayScreenState();
}

class _PaymentGatewayScreenState extends State<PaymentGatewayScreen> {
  int _selectedMethod = 0;

  static const _methods = <_PaymentMethod>[
    _PaymentMethod(Ph.apple_logo, 'Apple Pay'),
    _PaymentMethod(Ph.google_logo, 'Google Pay'),
    _PaymentMethod(Ph.credit_card, 'Credit Card'),
    _PaymentMethod(Ph.wallet, 'STC Pay'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, color: AppColors.lightText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Payment',
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Order summary card ──
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
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _orderRow('Court Booking', 'SR 150'),
                        const SizedBox(height: 10),
                        _orderRow('Racket Rental', 'SR 25'),
                        const SizedBox(height: 10),
                        _orderRow('Bottled Water (x2)', 'SR 10'),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.lightBorder, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: AppColors.lightText,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'SR 185',
                              style: TextStyle(
                                color: AppColors.lightText,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // ── Payment method heading ──
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // ── Payment method tiles ──
                  ...List.generate(_methods.length, (i) {
                    final method = _methods[i];
                    final selected = i == _selectedMethod;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMethod = i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.neonGreen.withValues(alpha: 0.08)
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColors.neonGreen
                                  : AppColors.lightBorder,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Iconify(
                                method.icon,
                                size: 26,
                                color: selected
                                    ? AppColors.lightText
                                    : AppColors.lightMuted,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  method.label,
                                  style: TextStyle(
                                    color: AppColors.lightText,
                                    fontSize: 15,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                width: 22,
                                height: 22,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.neonGreen
                                        : AppColors.lightBorder,
                                    width: selected ? 2 : 1.5,
                                  ),
                                  color: selected
                                      ? AppColors.neonGreen
                                      : Colors.transparent,
                                ),
                                child: selected
                                    ? const Icon(Icons.check,
                                        size: 14, color: AppColors.darkText)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  // ── Secure payment notice ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Iconify(Ph.lock,
                          color: AppColors.lightMuted, size: 14),
                      const SizedBox(width: 6),
                      const Text(
                        'Secure payment via SSL encryption',
                        style: TextStyle(
                          color: AppColors.lightMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // ── Bottom pay button ──
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.lightBg,
              border: Border(
                  top: BorderSide(color: AppColors.lightBorder, width: 0.5)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.bookingSuccess),
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
                child: const Text('Pay SR 185'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderRow(String label, String amount) {
    return Row(
      children: [
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
          amount,
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

class _PaymentMethod {
  final String icon;
  final String label;

  const _PaymentMethod(this.icon, this.label);
}