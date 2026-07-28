import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../../../theme/app_theme.dart';
import '../../../routes.dart';
import '../../../services/mock_data_service.dart';
import '../../providers/match_provider.dart';

/// Step 1 of match creation: pick court, date/time, level, gender, privacy & format.
class CreateMatchScreen extends ConsumerStatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  ConsumerState<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends ConsumerState<CreateMatchScreen> {
  // ── Helpers ──

  String _weekdayAbbr(int weekday) {
    const abbr = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return abbr[weekday];
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);
    final now = DateTime.now();
    final days =
        List.generate(7, (i) => DateTime(now.year, now.month, now.day + i));

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
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _stepDot(active: true),
                const SizedBox(width: 8),
                _stepConnector(active: true),
                const SizedBox(width: 8),
                _stepDot(active: false),
                const SizedBox(width: 8),
                Text(
                  'Step 1 of 2',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Sport & Court Selector ──
            _sectionLabel('Sport & Court', 'Choose your court'),
            const SizedBox(height: 12),
            _CourtCard(state: state, onTap: () => _openCourtPicker(notifier)),
            const SizedBox(height: 24),

            // ── 2. Date & Time ──
            _sectionLabel('Date & Time', 'Pick a date and time slot'),
            const SizedBox(height: 12),
            _buildDateStrip(days, state, notifier),
            const SizedBox(height: 16),
            _buildTimeSlots(state, notifier),
            const SizedBox(height: 24),

            // ── 3. Match Level ──
            _sectionLabel('Match Level', 'What skill level?'),
            const SizedBox(height: 12),
            _buildLevelChips(state, notifier),
            const SizedBox(height: 24),

            // ── 4. Gender ──
            _sectionLabel('Gender', 'Set match preference'),
            const SizedBox(height: 12),
            _buildGenderChips(state, notifier),
            const SizedBox(height: 24),

            // ── 5. Privacy & Format ──
            _sectionLabel('Privacy & Format', 'Who can join?'),
            const SizedBox(height: 12),
            _buildPrivacyToggle(state, notifier),
            const SizedBox(height: 16),
            _buildPlayerCount(state, notifier),
          ],
        ),
      ),
      // ── Fixed Bottom Bar ──
      bottomSheet: _buildBottomBar(state, notifier),
    );
  }

  // ── Section label ──

  Widget _sectionLabel(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }

  // ── Step indicator dots ──

  Widget _stepDot({required bool active}) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? AppColors.neonGreen : AppColors.darkBorder,
      ),
    );
  }

  Widget _stepConnector({required bool active}) {
    return Container(
      width: 24,
      height: 2,
      decoration: BoxDecoration(
        color: active ? AppColors.neonGreen : AppColors.darkBorder,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  // ── 1. Court Selector ──

  void _openCourtPicker(MatchCreationNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkField,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final courts = MockDataService.courts;
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final currentCourtId = ref.read(matchCreationProvider).courtId;
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.65,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.darkBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Iconify(Ph.tennis_ball,
                          color: AppColors.neonGreen, size: 22),
                      const SizedBox(width: 10),
                      const Text(
                        'Select Court',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.of(ctx).pop(),
                        child: const Iconify(Ph.x,
                            color: Colors.white60, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppColors.darkBorder, height: 1),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: courts.length,
                      itemBuilder: (_, i) {
                        final court = courts[i];
                        final selected = court.id == currentCourtId;
                        return GestureDetector(
                          onTap: () {
                            notifier.setCourt(
                                court.id, court.name, court.center, court.sportType);
                            setSheetState(() {});
                            Navigator.of(ctx).pop();
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.neonGreen.withValues(alpha: 0.08)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              border: selected
                                  ? Border.all(
                                      color: AppColors.neonGreen, width: 1.5)
                                  : null,
                            ),
                            child: Row(
                              children: [
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
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        court.name,
                                        style: TextStyle(
                                          color: selected
                                              ? AppColors.neonGreen
                                              : Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${court.center} • ${court.sportType}',
                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── 2. Date strip ──

  Widget _buildDateStrip(
    List<DateTime> days,
    MatchCreationState state,
    MatchCreationNotifier notifier,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: days.map((day) {
            final selected = state.selectedDate != null &&
                day.day == state.selectedDate!.day &&
                day.month == state.selectedDate!.month;
            return GestureDetector(
              onTap: () => notifier.setDate(day),
              child: Container(
                width: 56,
                height: 72,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.neonGreen : AppColors.darkSlate,
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
                    const SizedBox(height: 4),
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        color: selected ? AppColors.darkText : Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── 2b. Time slot chips ──

  Widget _buildTimeSlots(
    MatchCreationState state,
    MatchCreationNotifier notifier,
  ) {
    final date = state.selectedDate ?? DateTime.now();
    final slots = MockDataService.getTimeSlots(date);

    return Container(
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
              const Iconify(Ph.clock, color: AppColors.neonGreen, size: 20),
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
            children: slots.map((slot) {
              final selected = state.selectedTimeSlot == slot;
              return GestureDetector(
                onTap: () => notifier.setTimeSlot(slot),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color:
                        selected ? AppColors.neonGreen : AppColors.darkSlate,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected
                          ? AppColors.neonGreen
                          : AppColors.darkBorder,
                    ),
                  ),
                  child: Text(
                    slot,
                    style: TextStyle(
                      color: selected ? AppColors.darkText : Colors.white,
                      fontSize: 13,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 3. Level chips ──

  Widget _buildLevelChips(
    MatchCreationState state,
    MatchCreationNotifier notifier,
  ) {
    const levels = ['Beginner', 'Intermediate', 'Advanced', 'Open to All'];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: levels.map((level) {
        final selected = state.matchLevel == level;
        return GestureDetector(
          onTap: () => notifier.setMatchLevel(level),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? AppColors.neonGreen : AppColors.darkField,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppColors.neonGreen : AppColors.darkBorder,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Iconify(
                  selected ? Ph.check_circle : Ph.circle,
                  color: selected ? AppColors.darkText : Colors.white60,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  level,
                  style: TextStyle(
                    color: selected ? AppColors.darkText : Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── 4. Gender chips ──

  Widget _buildGenderChips(
    MatchCreationState state,
    MatchCreationNotifier notifier,
  ) {
    const genders = ['Male', 'Female', 'Mixed'];
    final icons = [Ph.gender_male, Ph.gender_female, Ph.users];

    return Row(
      children: List.generate(genders.length, (i) {
        final selected = state.gender == genders[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i > 0 ? 8 : 0,
              right: i < genders.length - 1 ? 8 : 0,
            ),
            child: GestureDetector(
              onTap: () => notifier.setGender(genders[i]),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.neonGreen.withValues(alpha: 0.1)
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
                      color: selected
                          ? AppColors.neonGreen
                          : Colors.white60,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      genders[i],
                      style: TextStyle(
                        color: selected
                            ? AppColors.neonGreen
                            : Colors.white,
                        fontSize: 13,
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
    );
  }

  // ── 5a. Privacy toggle ──

  Widget _buildPrivacyToggle(
    MatchCreationState state,
    MatchCreationNotifier notifier,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Iconify(
                state.isPrivate ? Ph.lock : Ph.globe,
                color: AppColors.neonGreen,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.isPrivate ? 'Private Match' : 'Open Match',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      state.isPrivate
                          ? 'Only invited players can join'
                          : 'Anyone can find and join this match',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => notifier.togglePrivacy(),
                child: Container(
                  width: 48,
                  height: 28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: state.isPrivate
                        ? AppColors.neonGreen
                        : AppColors.darkBorder,
                  ),
                  child: AnimatedAlign(
                    duration: const Duration(milliseconds: 200),
                    alignment: state.isPrivate
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 5b. Player count ──

  Widget _buildPlayerCount(
    MatchCreationState state,
    MatchCreationNotifier notifier,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkField,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          const Iconify(Ph.users, color: AppColors.neonGreen, size: 22),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Players',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: state.playerCount > 2
                    ? () => notifier.setPlayerCount(state.playerCount - 1)
                    : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.playerCount > 2
                        ? AppColors.neonGreen
                        : AppColors.darkBorder,
                  ),
                  child: const Icon(Icons.remove,
                      size: 20, color: AppColors.darkText),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${state.playerCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              GestureDetector(
                onTap: state.playerCount < 10
                    ? () => notifier.setPlayerCount(state.playerCount + 1)
                    : null,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: state.playerCount < 10
                        ? AppColors.neonGreen
                        : AppColors.darkBorder,
                  ),
                  child: const Icon(Icons.add,
                      size: 20, color: AppColors.darkText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 6. Bottom bar ──

  Widget _buildBottomBar(
    MatchCreationState state,
    MatchCreationNotifier notifier,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Price display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.darkField,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SR ${state.pricePerPlayer.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.neonGreen,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  '/ person',
                  style: TextStyle(color: Colors.white60, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Next button
          Expanded(
            child: SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: state.canProceedFromDetails
                    ? () {
                        notifier.setStep(MatchCreationStep.invitePlayers);
                        Navigator.of(context)
                            .pushNamed(Routes.invitePlayers);
                      }
                    : null,
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next: Invite Players'),
                    SizedBox(width: 6),
                    Iconify(Ph.arrow_right, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Court Selector Card ──

class _CourtCard extends StatelessWidget {
  final MatchCreationState state;
  final VoidCallback onTap;

  const _CourtCard({required this.state, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasCourt = state.courtId != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: hasCourt
              ? AppColors.neonGreen.withValues(alpha: 0.08)
              : AppColors.darkField,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasCourt ? AppColors.neonGreen : AppColors.darkBorder,
            width: hasCourt ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: hasCourt
                    ? AppColors.neonGreen.withValues(alpha: 0.15)
                    : AppColors.darkSlate,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Iconify(
                hasCourt ? Ph.tennis_ball : Ph.plus_circle,
                color:
                    hasCourt ? AppColors.neonGreen : Colors.white60,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: hasCourt
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.courtName!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${state.courtCenter} • ${state.sportType}',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      'Select a court',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 15,
                      ),
                    ),
            ),
            const Iconify(
              Ph.caret_down,
              color: Colors.white60,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
