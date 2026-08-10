import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/booking_provider.dart';
import '../services/models.dart';
import '../l10n/app_strings.dart';

class BookingStep2Screen extends ConsumerStatefulWidget {
  const BookingStep2Screen({super.key});

  @override
  ConsumerState<BookingStep2Screen> createState() => _BookingStep2ScreenState();
}

class _BookingStep2ScreenState extends ConsumerState<BookingStep2Screen> {
  int _selectedDuration = 0;
  Court? _court;

  static const _durations = [
    ('30 mins', 0.5),
    ('1 hour', 1.0),
    ('1.5 hours', 1.5),
    ('2 hours', 2.0),
  ];

  double get _hourlyRate => ref.watch(bookingStateProvider).court?.pricePerHour ?? 100;
  double get _totalPrice => _hourlyRate * _durations[_selectedDuration].$2;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bookingState = ref.read(bookingStateProvider);
    _court = bookingState.court;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context).t;
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22, color: AppColors.lightText),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  title: Text(t('addOns'), style: const TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
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
                _stepLine(false),
                _stepDot('3', false),
                _stepLine(false),
                _stepDot('4', false),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_court != null) ...[
                    Text(_court!.name, style: const TextStyle(color: AppColors.lightText, fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_court!.center, style: const TextStyle(color: AppColors.lightMuted, fontSize: 14)),
                  ],
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkField,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Row(
                      children: [
                        const Iconify(Ph.money, size: 24, color: AppColors.neonGreen),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t('ratePerHour'), style: const TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                            Text('SR ${_hourlyRate.toInt()}', style: const TextStyle(color: AppColors.lightText, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(t('selectDuration'), style: const TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...List.generate(_durations.length, (i) {
                    final active = _selectedDuration == i;
                    final price = (_hourlyRate * _durations[i].$2).toInt();
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDuration = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: active ? AppColors.neonGreen.withValues(alpha: 0.1) : AppColors.darkField,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: active ? AppColors.neonGreen : AppColors.darkBorder, width: active ? 2 : 1),
                        ),
                        child: Row(
                          children: [
                            Expanded(child: Text(_durations[i].$1, style: TextStyle(color: active ? AppColors.neonGreen : AppColors.lightMuted, fontSize: 15, fontWeight: FontWeight.w600))),
                            Text('SR $price', style: TextStyle(color: active ? AppColors.neonGreen : AppColors.white60, fontSize: 15, fontWeight: FontWeight.w700)),
                            if (active) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 20)],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.darkSlate, borderRadius: BorderRadius.circular(14)),
                    child: Row(
                      children: [
                        Text(t('total'), style: const TextStyle(color: AppColors.lightMuted, fontSize: 15)),
                        const Spacer(),
                        Text('SR ${_totalPrice.toInt()}', style: const TextStyle(color: AppColors.neonGreen, fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _court != null
                      ? () {
                          ref.read(bookingStateProvider.notifier).setDuration(_durations[_selectedDuration].$2);
                          final courtId = ModalRoute.of(context)?.settings.arguments as String?;
                          Navigator.of(context).pushNamed(
                            Routes.bookingStep3,
                            arguments: {
                              'courtId': courtId,
                              'durationIndex': _selectedDuration,
                              'durationLabel': _durations[_selectedDuration].$1,
                              'durationHours': _durations[_selectedDuration].$2,
                              'courtFee': _totalPrice,
                            },
                          );
                        }
                      : null,
                  child: Text(t('next')),
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
      width: 24, height: 24,
      decoration: BoxDecoration(color: active ? AppColors.neonGreen : AppColors.darkBorder, shape: BoxShape.circle),
      child: Center(child: Text(label, style: TextStyle(color: active ? AppColors.darkText : AppColors.white60, fontSize: 11, fontWeight: FontWeight.bold))),
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(child: Container(height: 2, margin: const EdgeInsets.symmetric(horizontal: 4), color: active ? AppColors.neonGreen : AppColors.darkBorder));
  }
}