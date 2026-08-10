import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/match_provider.dart';

/// "New Match" screen — pixel-matched to the Court+ App Workflows PDF.
class StartMatchScreen extends StatefulWidget {
  const StartMatchScreen({super.key});

  @override
  State<StartMatchScreen> createState() => _StartMatchScreenState();
}

class _StartMatchScreenState extends State<StartMatchScreen> {
  // Game & type
  int _selectedGame = 0; // 0=Padel, 1=Tennis
  int _selectedType = 1; // 0=1v1, 1=2v2 (2v2 selected in PDF)

  // Players
  final List<Map<String, String>> _players = [
    {'name': 'Khalid Al-Mansoor', 'avatar': 'https://i.pravatar.cc/150?u=khalid1'},
    {'name': 'Khalid Hassan', 'avatar': 'https://i.pravatar.cc/150?u=khalid2'},
  ];

  // Date & time
  DateTime _selectedDate = DateTime.now();
  String? _selectedTimeStr;
  String? _selectedLocation;

  // Level & gender
  int? _selectedLevel;
  int? _selectedGender; // 0=Female, 1=Male
  bool _acceptMembers = true;

  // Step tracking: 0=form, 1=date, 2=time, 3=location, 4=level modal, 5=gender modal, 6=review
  int _step = 0;

  static const _levels = [
    'Beginner', 'Intermediate', 'Intermediate high', 'Advanced', 'Competition',
  ];
  static const _locations = [
    ('Tennis Outdoor Court A', 'Eagle Sport Center', Ph.tennis_ball),
    ('Pro Tennis Arena', 'Al Malaz Club', Ph.tennis_ball),
    ('Elite Padel Court', 'Olaya District', Ph.target),
    ('Squash Pro Court', 'King Fahd District', Ph.circle),
  ];
  static const _timeSlots = [
    '06:00 AM', '07:00 AM', '08:00 AM', '09:00 AM',
    '10:00 AM', '11:00 AM', '12:00 PM', '01:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM', '05:00 PM',
    '06:00 PM', '07:00 PM', '08:00 PM', '09:00 PM',
    '10:00 PM', '11:00 PM',
  ];

  bool get _isComplete =>
      _selectedTimeStr != null &&
      _selectedLocation != null &&
      _selectedLevel != null &&
      _selectedGender != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Iconify(Ph.arrow_left, color: AppColors.lightText),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                _step == 6 ? 'Review Match' : 'New Match',
                style: const TextStyle(
                    color: AppColors.lightText, fontWeight: FontWeight.w700),
              ),
              centerTitle: true,
            ),
            Expanded(
              child: _step == 0
                  ? _buildForm()
                  : _step == 1
                      ? _buildDatePicker()
                      : _step == 2
                          ? _buildTimePicker()
                          : _step == 3
                              ? _buildLocationPicker()
                              : _step == 6
                                  ? _buildReview()
                                  : const SizedBox.shrink(),
            ),
            if (_step <= 3 && _step != 0) _buildConfirmBar(),
          ],
        ),
      ),
    );
  }

  // ── Main Form ──
  Widget _buildForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Select Game
          const _SectionLabel('Select Game'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _gameChip(0, Ph.target, 'Padel')),
              const SizedBox(width: 10),
              Expanded(child: _gameChip(1, Ph.tennis_ball, 'Tennis')),
            ],
          ),
          const SizedBox(height: 20),

          // Game Type
          const _SectionLabel('Game Type'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _typeChip(0, '1 vs 1')),
              const SizedBox(width: 10),
              Expanded(child: _typeChip(1, '2 vs 2')),
            ],
          ),
          const SizedBox(height: 20),

          // Add players
          const _SectionLabel('Add players to your match'),
          const SizedBox(height: 10),
          Row(
            children: [
              // Filled slots
              ..._players.map((p) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.lightField,
                          child: const Icon(Icons.person,
                              size: 22, color: AppColors.lightMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(p['name']!,
                            style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
              // Empty slots
              ...List.generate(4 - _players.length, (i) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.lightField,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.lightBorder, width: 1.5),
                          ),
                          child: const Icon(Icons.add,
                              size: 22, color: AppColors.lightMuted),
                        ),
                        const SizedBox(height: 4),
                        const Text('Available',
                            style: TextStyle(
                                color: AppColors.lightMuted, fontSize: 11)),
                      ],
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 20),

          // Form fields
          _formField(Ph.calendar, 'Date', 'Pick a day',
              onTap: () => setState(() => _step = 1)),
          const SizedBox(height: 12),
          _formField(Ph.map_pin, 'Location', 'Select Location',
              onTap: () => setState(() => _step = 3)),
          const SizedBox(height: 12),
          _formField(
              Ph.target, 'Match level', _selectedLevel != null ? _levels[_selectedLevel!] : 'Select level',
              onTap: _showLevelModal),
          const SizedBox(height: 12),
          _formField(
              Ph.gender_male, 'Gender', _selectedGender != null ? (_selectedGender == 0 ? 'Female' : 'Male') : 'Select gender',
              onTap: _showGenderModal),
          const SizedBox(height: 12),

          // Members toggle
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.lightField,
              borderRadius: BorderRadius.circular(14),
            ),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Iconify(Ph.lock, size: 20, color: AppColors.lightText),
              title: const Text('Members need to be accepted',
                  style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500)),
              value: _acceptMembers,
              activeThumbColor: AppColors.neonGreen,
              activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.4),
              onChanged: (v) => setState(() => _acceptMembers = v),
            ),
          ),
          const SizedBox(height: 24),

          // Create match button (black bg, green text per PDF)
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isComplete ? () => setState(() => _step = 6) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkSlate,
                foregroundColor: AppColors.neonGreen,
                disabledBackgroundColor: AppColors.lightField,
                disabledForegroundColor: AppColors.lightMuted,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create match',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _gameChip(int idx, String icon, String label) {
    final selected = _selectedGame == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedGame = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.neonGreen : AppColors.lightBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Iconify(icon,
                size: 22,
                color: selected ? AppColors.darkText : AppColors.lightMuted),
            const SizedBox(width: 8),
            Text(label,
                style: TextStyle(
                    color: selected ? AppColors.darkText : AppColors.lightText,
                    fontSize: 15,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _typeChip(int idx, String label) {
    final selected = _selectedType == idx;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = idx),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.neonGreen : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.neonGreen : AppColors.lightBorder,
          ),
        ),
        child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: selected ? AppColors.darkText : AppColors.lightText,
                fontSize: 15,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }

  Widget _formField(String icon, String label, String value,
      {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightField,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Iconify(icon, color: AppColors.lightText, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.lightMuted, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          color: AppColors.lightText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const Iconify(Ph.caret_right,
                color: AppColors.lightMuted, size: 16),
          ],
        ),
      ),
    );
  }

  // ── Date Picker ──
  Widget _buildDatePicker() {
    final now = DateTime.now();
    final days = List.generate(30, (i) => now.add(Duration(days: i)));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Row(
            children: [
              const Iconify(Ph.calendar, color: AppColors.lightText, size: 20),
              const SizedBox(width: 8),
              Text(_monthYear(_selectedDate),
                  style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                childAspectRatio: 0.85,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6),
            itemCount: days.length,
            itemBuilder: (_, i) {
              final day = days[i];
              final selected = day.day == _selectedDate.day &&
                  day.month == _selectedDate.month;
              return GestureDetector(
                onTap: () => setState(() => _selectedDate = day),
                child: Container(
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.neonGreen
                        : AppColors.lightField,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.lightBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_weekdayAbbr(day.weekday),
                          style: TextStyle(
                              color: selected
                                  ? AppColors.darkText
                                  : AppColors.lightMuted,
                              fontSize: 10)),
                      const SizedBox(height: 2),
                      Text('${day.day}',
                          style: TextStyle(
                              color: selected
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              fontSize: 15,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Time Picker ──
  Widget _buildTimePicker() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Time Slot',
              style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('Pick your preferred time',
              style: TextStyle(color: AppColors.lightMuted, fontSize: 14)),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_timeSlots.length, (i) {
                  final selected = _selectedTimeStr == _timeSlots[i];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedTimeStr = _timeSlots[i]),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.neonGreen
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: selected
                                ? AppColors.neonGreen
                                : AppColors.lightBorder),
                      ),
                      child: Text(_timeSlots[i],
                          style: TextStyle(
                              color: selected
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500)),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Location Picker ──
  Widget _buildLocationPicker() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('Select Court',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...List.generate(_locations.length, (i) {
          final loc = _locations[i];
          final selected = _selectedLocation == loc.$1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedLocation = loc.$1),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color:
                      selected ? AppColors.neonGreen.withValues(alpha: 0.08) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: selected ? AppColors.neonGreen : AppColors.lightBorder,
                      width: selected ? 1.5 : 1),
                ),
                child: Row(
                  children: [
                    Iconify(loc.$3,
                        color: selected
                            ? AppColors.neonGreen
                            : AppColors.lightMuted,
                        size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(loc.$1,
                              style: TextStyle(
                                  color: selected
                                      ? AppColors.neonGreen
                                      : AppColors.lightText,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text(loc.$2,
                              style: const TextStyle(
                                  color: AppColors.lightMuted,
                                  fontSize: 13)),
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
                                : AppColors.lightBorder,
                            width: selected ? 2 : 1.5),
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

  // ── Review Screen ──
  Widget _buildReview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _reviewRow(Ph.target, 'Game', _selectedGame == 0 ? 'Padel' : 'Tennis'),
          const SizedBox(height: 12),
          _reviewRow(Ph.users, 'Type', _selectedType == 0 ? '1 vs 1' : '2 vs 2'),
          const SizedBox(height: 12),
          if (_players.isNotEmpty) ...[
            _reviewRow(Ph.user_plus, 'Players', _players.map((p) => p['name']!).join(', ')),
            const SizedBox(height: 12),
          ],
          _reviewRow(Ph.calendar, 'Date', _formatDate(_selectedDate)),
          const SizedBox(height: 12),
          _reviewRow(Ph.clock, 'Time', _selectedTimeStr ?? ''),
          const SizedBox(height: 12),
          _reviewRow(Ph.map_pin, 'Location', _selectedLocation ?? ''),
          const SizedBox(height: 12),
          _reviewRow(Ph.target, 'Level', _levels[_selectedLevel!]),
          const SizedBox(height: 12),
          _reviewRow(Ph.gender_male, 'Gender',
              _selectedGender == 0 ? 'Female' : 'Male'),
          const SizedBox(height: 12),
          _reviewRow(Ph.shield_check, 'Accept',
              _acceptMembers ? 'Required' : 'Not required'),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: Consumer(
              builder: (context, ref, _) {
                final isLoading = ref.watch(matchCreationProvider).isLoading;
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Populate MatchCreationNotifier with all local state
                          final notifier = ref.read(matchCreationProvider.notifier);
                          notifier.setMatchLevel(_levels[_selectedLevel ?? 0]);
                          notifier.setGender(
                              _selectedGender == 0 ? 'Female' : 'Male');
                          notifier.setDate(_selectedDate);
                          notifier.setPlayerCount(
                              _selectedType == 1 ? 4 : 2);

                          // Attempt to set court info if available
                          if (_selectedLocation != null) {
                            // We use the name as both court and center placeholder
                            // since StartMatchScreen doesn't track court IDs
                            notifier.setCourt(
                              _selectedLocation!.hashCode.toString(),
                              _selectedLocation!,
                              '',
                              _selectedGame == 0 ? 'Padel' : 'Tennis',
                            );
                          }

                          // Call createMatch (inserts into Supabase matches table)
                          final error = await notifier.createMatch();
                          if (!mounted || !context.mounted) return;
                          if (error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Match created successfully!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.home,
                              (route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to create match: $error'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkSlate,
                    foregroundColor: AppColors.neonGreen,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.neonGreen,
                          ),
                        )
                      : const Text('Create match',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Confirm bar for sub-steps ──
  Widget _buildConfirmBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.lightBorder)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: () => setState(() => _step = 0),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkSlate,
            foregroundColor: AppColors.neonGreen,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('Confirm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // ── Level modal (PDF: "What's your level?") ──
  void _showLevelModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int temp = _selectedLevel ?? 0;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text("What's your level?",
                          style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.neonGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            size: 18, color: AppColors.darkText),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                    'In order to offer you better search results, we need to know your level.',
                    style:
                        TextStyle(color: AppColors.lightMuted, fontSize: 13)),
                const SizedBox(height: 20),
                ...List.generate(_levels.length, (i) {
                  final selected = i == temp;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GestureDetector(
                      onTap: () => setSheetState(() => temp = i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppColors.neonGreen.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: selected
                                  ? AppColors.neonGreen
                                  : AppColors.lightBorder),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(_levels[i],
                                  style: TextStyle(
                                      color: selected
                                          ? AppColors.neonGreen
                                          : AppColors.lightText,
                                      fontSize: 15)),
                            ),
                            Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: selected
                                    ? AppColors.neonGreen
                                    : AppColors.lightMuted,
                                size: 22),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedLevel = temp);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSlate,
                      foregroundColor: AppColors.neonGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Next',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Gender modal (PDF: Female/Male + Save) ──
  void _showGenderModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        int temp = _selectedGender ?? 0;
        return StatefulBuilder(
          builder: (ctx, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Gender',
                    style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _genderOption(
                          ctx, setSheetState, 0, Ph.gender_female, 'Female', temp),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _genderOption(
                          ctx, setSheetState, 1, Ph.gender_male, 'Male', temp),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _selectedGender = temp);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSlate,
                      foregroundColor: AppColors.neonGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _genderOption(BuildContext ctx, StateSetter setSheetState, int idx,
      String icon, String label, int current) {
    final selected = idx == current;
    return GestureDetector(
      onTap: () => setSheetState(() => current = idx), // ignore: invalid_use_of_protected_member
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonGreen.withValues(alpha: 0.08)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: selected ? AppColors.neonGreen : AppColors.lightBorder,
              width: selected ? 1.5 : 1),
        ),
        child: Column(
          children: [
            Iconify(icon,
                size: 32,
                color: selected ? AppColors.neonGreen : AppColors.lightMuted),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: selected ? AppColors.neonGreen : AppColors.lightText,
                    fontSize: 15,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──
  Widget _reviewRow(String icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.lightField,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Iconify(icon, size: 16, color: AppColors.lightText),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(color: AppColors.lightMuted, fontSize: 13)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
                color: AppColors.lightText,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  String _formatDate(DateTime d) => '${d.day} ${_monthYear(d)} ${d.year}';
  String _monthYear(DateTime d) {
    const months = [
      'January','February','March','April','May','June',
      'July','August','September','October','November','December'
    ];
    return months[d.month - 1];
  }
  String _weekdayAbbr(int wd) {
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return days[wd - 1];
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(
          color: AppColors.lightMuted,
          fontSize: 13,
          fontWeight: FontWeight.w600));
}