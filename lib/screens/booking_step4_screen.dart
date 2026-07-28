import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../services/models.dart';
import '../services/mock_data_service.dart';

class BookingStep4Screen extends StatefulWidget {
  const BookingStep4Screen({super.key});

  @override
  State<BookingStep4Screen> createState() => _BookingStep4ScreenState();
}

class _BookingStep4ScreenState extends State<BookingStep4Screen> {
  Court? _court;
  String _durationLabel = '';
  double _courtFee = 0;
  int _addonsSubtotal = 0;
  Map<String, int> _quantities = {};

  static const _addonPrices = {
    'Racket Rental': 20,
    'Ball Pack': 15,
    'Water Bottle': 5,
    'Towel': 10,
    'Wristband': 8,
  };

  double get _total => _courtFee + _addonsSubtotal;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && _court == null) {
      final courtId = args['courtId'] as String?;
      if (courtId != null) {
        _court = MockDataService.getCourtById(courtId);
      }
      _durationLabel = args['durationLabel'] as String? ?? '1 hour';
      _courtFee = (args['courtFee'] as num?)?.toDouble() ?? 0;
      _addonsSubtotal = (args['addonsSubtotal'] as num?)?.toInt() ?? 0;
      _quantities = (args['quantities'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, (v as num).toInt())) ??
          {};
    }
  }

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
          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                _stepDot('1', true),
                _stepLine(true),
                _stepDot('2', true),
                _stepLine(true),
                _stepDot('3', true),
                _stepLine(true),
                _stepDot('4', true),
              ],
            ),
          ),
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
                        if (_court != null) ...[
                          _summaryRow(Ph.tennis_ball, 'Court', _court!.name),
                          const SizedBox(height: 14),
                          _summaryRow(Ph.map_pin, 'Center', _court!.center),
                          const SizedBox(height: 14),
                        ],
                        _summaryRow(Ph.hourglass, 'Duration', _durationLabel),
                        const SizedBox(height: 14),
                        _summaryRow(Ph.money, 'Court Fee', 'SR ${_courtFee.toInt()}'),
                        if (_addonsSubtotal > 0) ...[
                          const SizedBox(height: 16),
                          const Divider(color: AppColors.darkBorder, height: 1),
                          const SizedBox(height: 16),
                          const Text(
                            'Add-ons',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._quantities.entries
                              .where((e) => e.value > 0)
                              .map((e) {
                            final price = (e.value * (_addonPrices[e.key] ?? 0));
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Iconify(Ph.check_circle,
                                      color: AppColors.neonGreen.withValues(alpha: 0.7),
                                      size: 16),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      '${e.key} x${e.value}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                                    ),
                                  ),
                                  Text(
                                    'SR $price',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          _summaryRow(
                            Ph.shopping_cart,
                            'Add-ons total',
                            'SR $_addonsSubtotal',
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Divider(color: AppColors.darkBorder, height: 1),
                        const SizedBox(height: 16),
                        // ── Price breakdown ──
                        _priceRow('Court Fee', 'SR ${_courtFee.toInt()}'),
                        const SizedBox(height: 8),
                        _priceRow('Add-ons', 'SR $_addonsSubtotal'),
                        const SizedBox(height: 12),
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
                              'SR ${_total.toInt()}',
                              style: const TextStyle(
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
                        Iconify(Ph.info, color: AppColors.neonGreen, size: 18),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Iconify(Ph.credit_card, size: 20),
                    const SizedBox(width: 8),
                    Text('Proceed to Pay - SR ${_total.toInt()}'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepDot(String label, bool active) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: active ? AppColors.neonGreen : AppColors.darkBorder,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.darkText : AppColors.white60,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        color: active ? AppColors.neonGreen : AppColors.darkBorder,
      ),
    );
  }

  Widget _summaryRow(String icon, String label, String value) {
    return Row(
      children: [
        Iconify(icon, color: AppColors.neonGreen, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white60, fontSize: 14),
          ),
        ),
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

  Widget _priceRow(String label, String amount) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const Spacer(),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}