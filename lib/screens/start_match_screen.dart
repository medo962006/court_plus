import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class StartMatchScreen extends StatefulWidget {
  const StartMatchScreen({super.key});

  @override
  State<StartMatchScreen> createState() => _StartMatchScreenState();
}

class _StartMatchScreenState extends State<StartMatchScreen> {
  int _currentStep = 1;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  int _selectedCourt = 0;
  int _selectedLevel = -1;
  int _selectedGender = 0;

  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];
  static const _genders = ['Male', 'Female', 'Any'];
  static const _stepLabels = ['Date', 'Time', 'Loc.', 'Level', 'Gender'];

  @override
  Widget build(BuildContext context) {
    final canContinue = _currentStep < 5 ||
        (_currentStep == 5 && _selectedLevel >= 0);

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
          'Start a Match',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Step indicator ──
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final stepNum = i + 1;
                final active = stepNum == _currentStep;
                final done = stepNum < _currentStep;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _stepCircle(stepNum, active, done),
                    if (i < 4)
                      Container(
                        width: 28,
                        height: 2,
                        color: done
                            ? AppColors.neonGreen
                            : AppColors.darkBorder,
                      ),
                  ],
                );
              }),
            ),
          ),
          // ── Step label row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(5, (i) {
                final done = i + 1 <= _currentStep;
                return Text(
                  _stepLabels[i],
                  style: TextStyle(
                    color: done ? AppColors.neonGreen : Colors.white30,
                    fontSize: 11,
                    fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.darkBorder, height: 1),
          // ── Content area ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
      // ── Fixed continue button ──
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.darkBg,
          border:
              Border(top: BorderSide(color: AppColors.darkBorder, width: 0.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: canContinue ? _onContinue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.neonGreen,
              foregroundColor: AppColors.darkText,
              disabledBackgroundColor: AppColors.darkField,
              disabledForegroundColor: Colors.white30,
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
            child: Text(_currentStep == 5 ? 'Continue' : 'Continue'),
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _datePicker();
      case 2:
        return _timePicker();
      case 3:
        return _courtSelector();
      case 4:
        return _genderSelector();
      case 5:
        return _levelSelector();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Step 1: Date picker ──
  Widget _datePicker() {
    final now = DateTime.now();
    final days = List.generate(14, (i) => now.add(Duration(days: i)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose a date for your match',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkField,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              // Month header
              Row(
                children: [
                  Iconify(Ph.calendar,
                      color: AppColors.neonGreen, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    _monthYear(_selectedDate),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Day chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: days.map((day) {
                  final selected = day.day == _selectedDate.day &&
                      day.month == _selectedDate.month;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = day),
                    child: Container(
                      width: 48,
                      height: 64,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.darkSlate,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.neonGreen
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekdayAbbr(day.weekday),
                            style: TextStyle(
                              color: selected
                                  ? AppColors.darkText
                                  : Colors.white60,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              color: selected
                                  ? AppColors.darkText
                                  : Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 2: Time picker ──
  Widget _timePicker() {
    final slots = [
      '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM',
      '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM',
      '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM',
      '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM',
      '10:00 PM', '11:00 PM',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Time Slot',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Pick your preferred time',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkField,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Iconify(Ph.clock, color: AppColors.neonGreen, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Available Slots',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(slots.length, (i) {
                  final selected = _selectedTime.hour == 6 + i;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTime =
                            TimeOfDay(hour: 6 + i, minute: 0);
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.darkSlate,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? AppColors.neonGreen
                              : AppColors.darkBorder,
                        ),
                      ),
                      child: Text(
                        slots[i],
                        style: TextStyle(
                          color: selected
                              ? AppColors.darkText
                              : Colors.white,
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 3: Court / Location selector ──
  Widget _courtSelector() {
    const courts = [
      ('Grand Slam Court', 'Riyadh Sports Center', Ph.tennis_ball),
      ('Pro Tennis Arena', 'Al Malaz Club', Ph.tennis_ball),
      ('Elite Padel Court', 'Olaya District', Ph.target),
      ('Squash Pro Court', 'King Fahd District', Ph.circle),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Court',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose your location',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 20),
        ...List.generate(courts.length, (i) {
          final selected = i == _selectedCourt;
          final court = courts[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCourt = i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.neonGreen.withValues(alpha: 0.08)
                      : AppColors.darkField,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.neonGreen : AppColors.darkBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Iconify(court.$3,
                        color: selected
                            ? AppColors.neonGreen
                            : Colors.white60,
                        size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            court.$1,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.neonGreen
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            court.$2,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
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
                              : AppColors.darkBorder,
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
      ],
    );
  }

  // ── Step 4: Gender selector ──
  Widget _genderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Gender',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Set match preference',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 20),
        Row(
          children: List.generate(_genders.length, (i) {
            final selected = i == _selectedGender;
            final icons = [Ph.gender_male, Ph.gender_female, Ph.users];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: i > 0 ? 8 : 0,
                  right: i < _genders.length - 1 ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGender = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.neonGreen.withValues(alpha: 0.08)
                          : AppColors.darkField,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.darkBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Iconify(
                          icons[i],
                          size: 28,
                          color: selected
                              ? AppColors.neonGreen
                              : Colors.white60,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _genders[i],
                          style: TextStyle(
                            color: selected
                                ? AppColors.neonGreen
                                : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // ── Step 5: Match level ──
  Widget _levelSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Match Level',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select your playing level',
          style: TextStyle(color: Colors.white60, fontSize: 14),
        ),
        const SizedBox(height: 20),
        ...List.generate(_levels.length, (i) {
          final selected = i == _selectedLevel;
          final icons = [Ph.student, Ph.chart_bar, Ph.lightning];
          final descs = [
            'New to the game, learning the basics',
            'Can rally and play with consistent form',
            'Experienced with strong game strategy',
          ];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedLevel = i),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.neonGreen.withValues(alpha: 0.08)
                      : AppColors.darkField,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        selected ? AppColors.neonGreen : AppColors.darkBorder,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Iconify(icons[i],
                        color: selected
                            ? AppColors.neonGreen
                            : Colors.white60,
                        size: 26),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _levels[i],
                            style: TextStyle(
                              color: selected
                                  ? AppColors.neonGreen
                                  : Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            descs[i],
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
                              : AppColors.darkBorder,
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
      ],
    );
  }

  // ── Helpers ──
  Widget _stepCircle(int step, bool active, bool done) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done
            ? AppColors.neonGreen
            : active
                ? AppColors.neonGreen.withValues(alpha: 0.15)
                : AppColors.darkField,
        border: Border.all(
          color: active || done ? AppColors.neonGreen : AppColors.darkBorder,
          width: active ? 2 : 1.5,
        ),
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check, size: 16, color: AppColors.darkText)
            : Text(
                '$step',
                style: TextStyle(
                  color: active ? AppColors.neonGreen : Colors.white60,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _onContinue() {
    if (_currentStep < 5) {
      setState(() => _currentStep++);
    } else {
      Navigator.of(context).pushNamed(Routes.addPlayers);
    }
  }

  String _monthYear(DateTime d) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[d.month - 1]} ${d.year}';
  }

  String _weekdayAbbr(int wd) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[wd - 1];
  }
}