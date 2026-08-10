import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';

import '../../../routes.dart';
import '../../../services/models.dart';
import '../../providers/invitations_provider.dart';

/// Screen displaying match invitation details with hero banner,
/// parameters, player roster, split payment, and accept/decline actions.
class InvitationDetailsScreen extends ConsumerWidget {
  final Invitation invitation;

  const InvitationDetailsScreen({super.key, required this.invitation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(invitationsNotifierProvider.notifier);
    final isPending = invitation.status == InvitationStatus.pending;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Invitation Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeroBanner(),
              _buildParamsCard(),
              _buildHostMessage(),
              if (isPending) _buildActionButtons(context, notifier),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
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
          Image.asset(
            'assets/images/court1.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, err, stack) =>
                Container(color: Colors.grey[300]),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black54],
              ),
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                invitation.courtName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 12,
            child: Text(
              'Invitation from ${invitation.senderId.length > 16 ? '${invitation.senderId.substring(0, 16)}...' : invitation.senderId}',
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
            _ParamRow(
                icon: Ph.calendar_blank,
                label: 'Date',
                value: invitation.date),
            const Divider(height: 20),
            _ParamRow(
                icon: Ph.clock,
                label: 'Time',
                value: invitation.timeSlot),
            const Divider(height: 20),
            _ParamRow(
                icon: Ph.map_pin,
                label: 'Court',
                value: invitation.courtName),
            if (invitation.matchId != null) ...[
              const Divider(height: 20),
              _ParamRow(
                  icon: Ph.identification_card,
                  label: 'Match ID',
                  value: invitation.matchId!.length > 12
                      ? '...${invitation.matchId!.substring(invitation.matchId!.length - 12)}'
                      : invitation.matchId!),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Message from Sender
  // ---------------------------------------------------------------------------
  Widget _buildHostMessage() {
    if (invitation.message == null || invitation.message!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.green.withValues(alpha: 0.2),
            child: Text(
              invitation.senderId.isNotEmpty
                  ? invitation.senderId[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
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
                    'Message',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    invitation.message!,
                    style: const TextStyle(
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
  // 4. Action Buttons (only for pending)
  // ---------------------------------------------------------------------------
  Widget _buildActionButtons(BuildContext context, InvitationsNotifier notifier) {
    const neonGreen = Color(0xFF39FF14);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () async {
                final error = await notifier.respondToInvitation(
                    invitation.id, 'declined');
                if (context.mounted) {
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $error')),
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                }
              },
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
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () async {
                final error = await notifier.respondToInvitation(
                    invitation.id, 'accepted');
                if (context.mounted) {
                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed: $error')),
                    );
                  } else {
                    Navigator.of(context).pushNamed(Routes.paymentGateway);
                  }
                }
              },
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