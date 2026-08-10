import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

import '../../../theme/app_theme.dart';
import '../../../routes.dart';
import '../../../services/models.dart';
import '../../providers/match_provider.dart';
import '../../providers/supabase_provider.dart';

// ─── Player search from Supabase profiles ───

/// A display-ready player item built from a Supabase UserProfile.
class PlayerSearchResult {
  final String userId;
  final String name;
  final String handle;
  final String level;

  const PlayerSearchResult({
    required this.userId,
    required this.name,
    required this.handle,
    this.level = 'Intermediate',
  });

  factory PlayerSearchResult.fromProfile(UserProfile profile) {
    return PlayerSearchResult(
      userId: profile.id,
      name: profile.fullName.isNotEmpty ? profile.fullName : profile.username,
      handle: profile.username,
    );
  }
}

// ─── Screen ───

class InvitePlayersScreen extends ConsumerStatefulWidget {
  const InvitePlayersScreen({super.key});

  @override
  ConsumerState<InvitePlayersScreen> createState() =>
      _InvitePlayersScreenState();
}

class _InvitePlayersScreenState extends ConsumerState<InvitePlayersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<PlayerSearchResult> _searchResults = [];
  bool _isSearching = false;

  /// Search profiles from Supabase by name or username.
  Future<void> _searchProfiles(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final service = ref.read(supabaseServiceProvider);
      // Fetch profiles matching the search term (ILIKE on full_name or username)
      final response = await service.client
          .from('profiles')
          .select('id, full_name, username')
          .or('full_name.ilike.%$q%,username.ilike.%$q%')
          .limit(20);

      final results = (response as List)
          .map((e) => PlayerSearchResult(
                userId: e['id'] as String? ?? '',
                name: e['full_name'] as String? ?? '',
                handle: e['username'] as String? ?? '',
              ))
          .where((r) => r.userId.isNotEmpty)
          .toList();

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchCreationProvider);
    final notifier = ref.read(matchCreationProvider.notifier);

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
        title: Column(
          children: [
            const Text(
              'Invite Players',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Step 2 of 2',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => _searchProfiles(v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search players by name or phone...',
                hintStyle:
                    const TextStyle(color: AppColors.white60, fontSize: 14),
                prefixIcon: const Iconify(Ph.magnifying_glass,
                    color: AppColors.white60, size: 18),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Iconify(Ph.x_circle_fill,
                            color: AppColors.white60, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.darkField,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.darkBorder, width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: AppColors.darkBorder, width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.neonGreen, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Match capacity counter ──
          _CapacityCard(
            invitedCount: state.invitedPlayerIds.length,
            totalCount: state.playerCount,
          ),

          const SizedBox(height: 8),

          // ── Section header ──
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Suggested Players',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── Suggested players list ──
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: AppColors.neonGreen))
                : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _searchResults.length,
              separatorBuilder: (context, idx) =>
                  const Divider(color: AppColors.darkBorder, height: 1),
              itemBuilder: (context, index) {
                final player = _searchResults[index];
                final isInvited =
                    state.invitedPlayerIds.contains(player.userId);
                return _PlayerRow(
                  player: player,
                  isInvited: isInvited,
                  onToggle: () => notifier.toggleInvitedPlayer(player.userId),
                );
              },
            ),
          ),

          // ── Share invite link card ──
          _ShareLinkCard(),

          const SizedBox(height: 8),
        ],
      ),

      // ── Bottom bar ──
      bottomSheet: _BottomBar(
        pricePerPlayer: state.pricePerPlayer,
        slotsFilled: state.invitedPlayerIds.length,
        totalSlots: state.playerCount,
        isLoading: state.isLoading,
        onCreateAndPay: () async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final error = await notifier.createMatch();
          if (error == null) {
            navigator.pushNamedAndRemoveUntil(Routes.home, (r) => false);
          } else {
            messenger.showSnackBar(
              SnackBar(content: Text('Failed: $error')),
            );
          }
        },
      ),
    );
  }
}

// ─── Capacity Card ───

class _CapacityCard extends StatelessWidget {
  final int invitedCount;
  final int totalCount;

  const _CapacityCard({
    required this.invitedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? invitedCount / totalCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkField,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Iconify(Ph.users,
                    color: AppColors.neonGreen, size: 20),
                const SizedBox(width: 8),
                Text(
                  '$invitedCount / $totalCount Players Added',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.darkBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.neonGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Player Row ───

class _PlayerRow extends StatelessWidget {
  final PlayerSearchResult player;
  final bool isInvited;
  final VoidCallback onToggle;

  const _PlayerRow({
    required this.player,
    required this.isInvited,
    required this.onToggle,
  });

  Color _levelColor(String level) {
    switch (level) {
      case 'Advanced':
        return AppColors.neonGreen;
      case 'Intermediate':
        return const Color(0xFF4FC3F7);
      case 'Beginner':
        return const Color(0xFFFFB74D);
      default:
        return AppColors.white60;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.darkField,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person,
                color: AppColors.white60, size: 22),
          ),
          const SizedBox(width: 12),
          // Name + handle + level badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _levelColor(player.level)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        player.level,
                        style: TextStyle(
                          color: _levelColor(player.level),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '@${player.handle}',
                  style: const TextStyle(
                      color: AppColors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
          // Invite / Invited toggle
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isInvited
                    ? AppColors.neonGreen.withValues(alpha: 0.15)
                    : AppColors.darkField,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isInvited
                      ? AppColors.neonGreen
                      : AppColors.darkBorder,
                ),
              ),
              child: Text(
                isInvited ? 'Invited' : '+ Invite',
                style: TextStyle(
                  color: isInvited
                      ? AppColors.neonGreen
                      : AppColors.white60,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Share Link Card ───

class _ShareLinkCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkField,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Iconify(Ph.share_network,
                  color: AppColors.neonGreen, size: 22),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Share Invite Link',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Send invite link to your friends',
                    style: TextStyle(
                      color: AppColors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share link copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.darkField,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Iconify(Ph.whatsapp_logo,
                        color: Color(0xFF25D366), size: 16),
                    const SizedBox(width: 6),
                    const Text(
                      'Share via WhatsApp',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom Bar ───

class _BottomBar extends StatelessWidget {
  final double pricePerPlayer;
  final int slotsFilled;
  final int totalSlots;
  final bool isLoading;
  final VoidCallback onCreateAndPay;

  const _BottomBar({
    required this.pricePerPlayer,
    required this.slotsFilled,
    required this.totalSlots,
    required this.isLoading,
    required this.onCreateAndPay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: AppColors.darkBg,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Price & slots info
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SR ${pricePerPlayer.toStringAsFixed(0)} / person',
                    style: const TextStyle(
                      color: AppColors.neonGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$slotsFilled slots filled',
                    style: const TextStyle(
                      color: AppColors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            // Create Match & Pay button
            SizedBox(
              width: 180,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : onCreateAndPay,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: AppColors.darkText,
                  disabledBackgroundColor: AppColors.darkField,
                  disabledForegroundColor: AppColors.white60,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.darkText,
                        ),
                      )
                    : const Text(
                        'Create Match & Pay',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}