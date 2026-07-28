import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class MatchFilterScreen extends StatefulWidget {
  const MatchFilterScreen({super.key});

  @override
  State<MatchFilterScreen> createState() => _MatchFilterScreenState();
}

class _MatchFilterScreenState extends State<MatchFilterScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeSlot;
  final TextEditingController _locationController = TextEditingController();
  String? _selectedLevel;
  String? _selectedGender;

  static const _timeSlots = [
    '06:00', '07:00', '08:00', '09:00', '10:00',
    '11:00', '12:00', '13:00', '14:00', '15:00',
    '16:00', '17:00', '18:00', '19:00', '20:00',
    '21:00', '22:00',
  ];

  static const _levels = ['Beginner', 'Intermediate', 'Advanced'];
  static const _genders = ['Male', 'Female', 'Mixed'];

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.neonGreen,
            onPrimary: AppColors.darkText,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Filter',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          // ── Date picker ──
          const _SectionLabel('Date'),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.lightBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Row(
                children: [
                  const Iconify(Ph.calendar_blank,
                      color: AppColors.lightText, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                        color: AppColors.lightText,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  const Iconify(Ph.caret_down,
                      color: AppColors.lightMuted, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Time slot grid ──
          const _SectionLabel('Time'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((slot) {
              final selected = _selectedTimeSlot == slot;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedTimeSlot = selected ? null : slot;
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.neonGreen.withAlpha(25)
                        : AppColors.lightBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? AppColors.neonGreen
                          : AppColors.lightBorder,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: selected
                          ? AppColors.neonGreen
                          : AppColors.lightText,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Location search ──
          const _SectionLabel('Location'),
          const SizedBox(height: 8),
          TextField(
            controller: _locationController,
            style: const TextStyle(color: AppColors.lightText, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search location…',
              hintStyle:
                  const TextStyle(color: AppColors.lightMuted, fontSize: 14),
              prefixIcon: const Iconify(Ph.magnifying_glass,
                  color: AppColors.lightMuted, size: 18),
              suffixIcon: _locationController.text.isNotEmpty
                  ? IconButton(
                      icon: const Iconify(Ph.x_circle_fill,
                          color: AppColors.lightMuted, size: 18),
                      onPressed: () {
                        _locationController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.lightBg,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.lightBorder, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.lightBorder, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: AppColors.neonGreen, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Level chips ──
          const _SectionLabel('Level'),
          const SizedBox(height: 8),
          Row(
            children: _levels.map((level) {
              final selected = _selectedLevel == level;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedLevel = selected ? null : level;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.neonGreen.withAlpha(25)
                          : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.lightBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      level,
                      style: TextStyle(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.lightText,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // ── Gender chips ──
          const _SectionLabel('Gender'),
          const SizedBox(height: 8),
          Row(
            children: _genders.map((gender) {
              final selected = _selectedGender == gender;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() {
                    _selectedGender = selected ? null : gender;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.neonGreen.withAlpha(25)
                          : AppColors.lightBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.lightBorder,
                        width: selected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      gender,
                      style: TextStyle(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.lightText,
                        fontSize: 13,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // ── Show Results button ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.neonGreen,
                foregroundColor: AppColors.darkText,
                minimumSize: const Size.fromHeight(54),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Show Results',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final day = d.day;
    final month = months[d.month - 1];
    final year = d.year;
    final today = DateTime.now();
    if (d.year == today.year && d.month == today.month && d.day == today.day) {
      return 'Today, $day $month $year';
    }
    final tomorrow = today.add(const Duration(days: 1));
    if (d.year == tomorrow.year &&
        d.month == tomorrow.month &&
        d.day == tomorrow.day) {
      return 'Tomorrow, $day $month $year';
    }
    const weekdays = [
      'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
    ];
    return '${weekdays[d.weekday - 1]}, $day $month $year';
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: const TextStyle(
            color: AppColors.lightText,
            fontSize: 14,
            fontWeight: FontWeight.w700));
  }
}