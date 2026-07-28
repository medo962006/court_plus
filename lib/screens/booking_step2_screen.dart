import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class BookingStep2Screen extends StatefulWidget {
  const BookingStep2Screen({super.key});

  @override
  State<BookingStep2Screen> createState() => _BookingStep2ScreenState();
}

class _BookingStep2ScreenState extends State<BookingStep2Screen> {
  int _selectedDuration = 1; // index
  static const _durations = [
    ('30 mins', 0.5),
    ('1 hour', 1.0),
    ('1.5 hours', 1.5),
    ('2 hours', 2.0),
  ];
  static const _hourlyRate = 100;

  double get _totalPrice => _hourlyRate * _durations[_selectedDuration].$2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      appBar: AppBar(
        backgroundColor: AppColors.darkBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Booking',
            style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          children: const [
                            Text('Rate per hour',
                                style: TextStyle(color: AppColors.white60, fontSize: 13)),
                            Text('SR 100',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Duration',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...List.generate(_durations.length, (i) {
                    final active = _selectedDuration == i;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedDuration = i),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: active ? AppColors.neonGreen.withValues(alpha: 0.1) : AppColors.darkField,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active ? AppColors.neonGreen : AppColors.darkBorder,
                            width: active ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(_durations[i].$1,
                                  style: TextStyle(
                                      color: active ? AppColors.neonGreen : Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600)),
                            ),
                            Text('SR ${(_hourlyRate * _durations[i].$2).toInt()}',
                                style: TextStyle(
                                    color: active ? AppColors.neonGreen : AppColors.white60,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                            if (active) ...[
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle, color: AppColors.neonGreen, size: 20),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.darkSlate,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Text('Total',
                            style: TextStyle(color: AppColors.white60, fontSize: 15)),
                        const Spacer(),
                        Text('SR ${_totalPrice.toInt()}',
                            style: const TextStyle(
                                color: AppColors.neonGreen,
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
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
                  onPressed: () => Navigator.of(context).pushNamed(Routes.bookingStep3),
                  child: const Text('Next'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}