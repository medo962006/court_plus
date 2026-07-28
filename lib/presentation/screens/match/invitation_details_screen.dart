import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

import '../../../routes.dart';

/// Screen displaying match invitation details with hero banner,
/// parameters, player roster, split payment, and accept/decline actions.
class InvitationDetailsScreen extends ConsumerStatefulWidget {
  const InvitationDetailsScreen({super.key});

  @override
  ConsumerState<InvitationDetailsScreen> createState() =>
      _InvitationDetailsScreenState();
}

class _InvitationDetailsScreenState
    extends ConsumerState<InvitationDetailsScreen> {
  // ---------------------------------------------------------------------------
  // Sample data – in a real app these would come from the route argument or
  // a provider loaded by the invitation id.
  // ---------------------------------------------------------------------------
  static const _sportType = 'Tennis';
  static const _organizer = '@hafezs';
  static const _date = '15 April 2024';
  static const _time = '07:00 - 08:00';
  static const _location = 'Eagle Sport Center, Court A';
  static const _level = 'Intermediate · Mixed';
  static const _totalFee = 100;
  static const _splitCount = 4;
  static const _hostMessage =
      'Hey! Looking for one more for tomorrow morning. Let me know if you\'re in!';

  final List<_PlayerSlot> _players = const [
    _PlayerSlot(name: 'Hafez', confirmed: true),
    _PlayerSlot(name: 'Sara', confirmed: true),
    _PlayerSlot(name: 'Ali', confirmed: true),
    _PlayerSlot(name: null, confirmed: false), // open slot
  ];

  int get _yourShare => _totalFee ~/ _splitCount;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroBanner(),
              _buildParamsCard(),
              _buildPlayerRoster(),
              _buildSplitPaymentBox(),
              _buildHostMessage(),
              _buildActionButtons(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Invitation Details'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      ),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Hero Banner
  // ---------------------------------------------------------------------------
  Widget _buildHeroBanner() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/court1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, err, stack) => Container(color: Colors.grey[300]),
          ),

          // Dark gradient overlay for readability
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),

          // Sport type pill – top-left
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                _sportType,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Organizer label – bottom-left
          Positioned(
            bottom: 12,
            left: 12,
            child: Text(
              'Organized by $_organizer',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    blurRadius: 6,
                    color: Colors.black45,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Match Parameters Summary Card
  // ---------------------------------------------------------------------------
  Widget _buildParamsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Column(
          children: [
            _ParamRow(icon: Ph.calendar_blank, label: 'Date', value: _date),
            const Divider(height: 20),
            _ParamRow(icon: Ph.clock, label: 'Time', value: _time),
            const Divider(height: 20),
            _ParamRow(icon: Ph.map_pin, label: 'Location', value: _location),
            const Divider(height: 20),
            _ParamRow(icon: Ph.medal, label: 'Level', value: _level),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Player Roster Grid (2x2)
  // ---------------------------------------------------------------------------
  Widget _buildPlayerRoster() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Players',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemCount: _players.length,
            itemBuilder: (context, index) => _buildPlayerSlot(_players[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerSlot(_PlayerSlot slot) {
    if (slot.confirmed && slot.name != null) {
      // Filled slot
      return Container(
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green.withValues(alpha: 0.2),
              child: Text(
                slot.name![0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              slot.name!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      );
    } else {
      // Open slot
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[400]!,
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.grey),
            ),
            const SizedBox(width: 8),
            Text(
              'Open',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Split Payment Box
  // ---------------------------------------------------------------------------
  Widget _buildSplitPaymentBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Court Fee',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              Text(
                'SR $_totalFee',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Split',
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              Text(
                '$_splitCount players',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Share',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'SR $_yourShare',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. Message from Host
  // ---------------------------------------------------------------------------
  Widget _buildHostMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Host avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green.withValues(alpha: 0.2),
            child: Text(
              'H',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _organizer,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    _hostMessage,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Action Buttons
  // ---------------------------------------------------------------------------
  Widget _buildActionButtons() {
    const neonGreen = Color(0xFF39FF14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Decline
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey[300]!),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Decline',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Accept & Pay Share
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.paymentGateway),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: neonGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 2,
              ),
              child: const Text(
                'Accept & Pay Share',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Supporting widgets
// =============================================================================

/// A single row inside the match parameters card.
class _ParamRow extends StatelessWidget {
  const _ParamRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Iconify(icon, size: 20, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[500],
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}

/// Data class representing a player slot in the roster.
class _PlayerSlot {
  const _PlayerSlot({required this.name, required this.confirmed});

  final String? name;
  final bool confirmed;
}