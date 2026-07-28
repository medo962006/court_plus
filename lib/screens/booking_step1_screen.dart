import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class BookingStep1Screen extends StatefulWidget {
  const BookingStep1Screen({super.key});

  @override
  State<BookingStep1Screen> createState() => _BookingStep1ScreenState();
}

class _BookingStep1ScreenState extends State<BookingStep1Screen> {
  int? _selectedDay;
  int? _selectedTime;
  final List<String> _timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00',
    '11:00', '12:00', '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00', '19:00', '20:00',
  ];
  static const _available = {2, 5, 8, 11, 14, 17, 20, 23, 26, 29};

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
                  const Text('Tennis Outdoor Court A',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('Eagle Sport Center',
                      style: TextStyle(color: AppColors.white60, fontSize: 14)),
                  const SizedBox(height: 24),
                  const Text('Select Date',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildCalendar(),
                  const SizedBox(height: 24),
                  const Text('Select Time',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(_timeSlots.length, (i) {
                      final active = _selectedTime == i;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedTime = i),
                        child: Container(
                          width: (MediaQuery.of(context).size.width - 60) / 3,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: active ? AppColors.neonGreen : AppColors.darkField,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active ? AppColors.neonGreen : AppColors.darkBorder,
                            ),
                          ),
                          child: Text(
                            _timeSlots[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: active ? AppColors.darkText : Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
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
                  onPressed: () => Navigator.of(context).pushNamed(Routes.bookingStep2),
                  child: const Text('Next'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Iconify(Ph.caret_left_bold, size: 18, color: AppColors.white60),
              Text('April 2024',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
              Iconify(Ph.caret_right_bold, size: 18, color: AppColors.white60),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(
                    child: Center(
                        child: Text(d, style: const TextStyle(color: AppColors.white60, fontSize: 12, fontWeight: FontWeight.w600)))))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(5, (week) {
            return Row(
              children: List.generate(7, (dow) => Expanded(child: _dayCell(week, dow))),
            );
          }),
        ],
      ),
    );
  }

  Widget _dayCell(int week, int dow) {
    final n = week * 7 + dow;
    if (n < 1 || n > 30) return const SizedBox(height: 40);
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
          child: Text('$n', style: TextStyle(
            fontSize: 13,
            fontWeight: available ? FontWeight.w700 : FontWeight.w400,
            color: selected ? Colors.black : available ? const Color(0xFF7CB800) : AppColors.white60.withValues(alpha: 0.5),
          )),
        ),
      ),
    );
  }
}