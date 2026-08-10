import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/booking_provider.dart';
import '../presentation/providers/courts_provider.dart';
import '../services/models.dart';
import '../presentation/providers/supabase_provider.dart';
import '../l10n/app_strings.dart';

class BookingStep1Screen extends ConsumerStatefulWidget {
  const BookingStep1Screen({super.key});

  @override
  ConsumerState<BookingStep1Screen> createState() => _BookingStep1ScreenState();
}

class _BookingStep1ScreenState extends ConsumerState<BookingStep1Screen> {
  int? _selectedDay;
  String? _selectedTimeStr;
  Court? _court;
  List<String> _timeSlots = [];
  bool _loadingSlots = false;
  String? _courtId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_courtId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        _courtId = args;
      } else if (args is Map) {
        _courtId = (args['id'] ?? args['court_id'] ?? '') as String?;
      }

      if (_courtId != null) {
        ref.read(courtsProvider).whenData((courts) {
          final found = courts.where((c) => c.id == _courtId).firstOrNull;
          if (found != null && mounted) {
            setState(() => _court = found);
            ref.read(bookingStateProvider.notifier).setCourt(found);
          }
        });
      }
    }
  }

  Future<void> _fetchSlots(DateTime date) async {
    if (_courtId == null) return;
    setState(() => _loadingSlots = true);
    final service = ref.read(supabaseServiceProvider);
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final result = await service.getAvailableSlots(
      courtId: _courtId!,
      date: dateStr,
    );
    result.fold(
      (slots) {
        if (!mounted) return;
        setState(() {
          _timeSlots = slots
              .map((s) {
                final time = s['start_time'] as String? ?? '';
                if (time.length >= 5) return time.substring(0, 5);
                return time;
              })
              .where((t) => t.isNotEmpty)
              .toList();
          _loadingSlots = false;
        });
      },
      (_) {
        if (!mounted) return;
        setState(() => _loadingSlots = false);
      },
    );
  }

  void _onDaySelected(int day) {
    final now = DateTime.now();
    final date = DateTime(now.year, now.month, day);
    setState(() {
      _selectedDay = day;
      _selectedTimeStr = null;
    });
    _fetchSlots(date);
  }

  void _navigateToStep2() {
    if (_court == null || _selectedDay == null || _selectedTimeStr == null) return;
    final now = DateTime.now();
    ref.read(bookingStateProvider.notifier).setCourt(_court!);
    ref.read(bookingStateProvider.notifier).setDate(DateTime(now.year, now.month, _selectedDay!));
    ref.read(bookingStateProvider.notifier).setTimeSlot(_selectedTimeStr!);
    Navigator.of(context).pushNamed(Routes.bookingStep2);
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
        title: Text(t('booking'), style: const TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
      ),
      body: Column(
        children: [
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
                  ] else ...[
                    Text(t('selectCourt'), style: const TextStyle(color: AppColors.lightText, fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                  const SizedBox(height: 24),
                  Text(t('selectDate'), style: const TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _buildCalendar(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(t('selectTime'), style: const TextStyle(color: AppColors.lightText, fontSize: 16, fontWeight: FontWeight.w700)),
                      if (_loadingSlots) ...[
                        const SizedBox(width: 10),
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.neonGreen)),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedDay != null && _timeSlots.isEmpty && !_loadingSlots)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Center(
                        child: Text(
                          t('noAvailableSlots'),
                          style: const TextStyle(color: AppColors.lightMuted, fontSize: 14),
                        ),
                      ),
                    ),
                  if (_timeSlots.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: List.generate(_timeSlots.length, (i) {
                        final active = _selectedTimeStr == _timeSlots[i];
                        return GestureDetector(
                          onTap: () => setState(() => _selectedTimeStr = _timeSlots[i]),
                          child: Container(
                            width: (MediaQuery.of(context).size.width - 60) / 3,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: active ? AppColors.neonGreen : AppColors.lightField,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: active ? AppColors.neonGreen : AppColors.lightBorder),
                            ),
                            child: Text(_timeSlots[i], textAlign: TextAlign.center, style: TextStyle(
                              color: active ? AppColors.darkText : AppColors.lightText,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            )),
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
                  onPressed: _selectedDay != null && _selectedTimeStr != null && _court != null
                      ? _navigateToStep2
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

  Widget _buildCalendar() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final firstWeekday = DateTime(now.year, now.month, 1).weekday % 7;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Iconify(Ph.caret_left_bold, size: 18, color: AppColors.lightMuted),
              Text(
                '${_monthName(now.month)} ${now.year}',
                style: const TextStyle(color: AppColors.lightText, fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const Iconify(Ph.caret_right_bold, size: 18, color: AppColors.lightMuted),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(color: AppColors.lightMuted, fontSize: 12, fontWeight: FontWeight.w600)))))
                .toList(),
          ),
          const SizedBox(height: 8),
          ...List.generate(6, (week) {
            return Row(
              children: List.generate(7, (dow) {
                final n = week * 7 + dow - firstWeekday + 1;
                if (n < 1 || n > daysInMonth) return const Expanded(child: SizedBox(height: 40));
                final selected = _selectedDay == n;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => _onDaySelected(n),
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
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.black : AppColors.lightText,
                        )),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }
}