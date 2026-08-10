import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../presentation/providers/invitations_provider.dart';
import '../services/models.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class ReceiveInvitationScreen extends ConsumerWidget {
  const ReceiveInvitationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invitationsAsync = ref.watch(invitationsNotifierProvider);
    final notifier = ref.read(invitationsNotifierProvider.notifier);

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
        title: const Text('Invitations',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Iconify(Ph.arrow_clockwise, size: 20),
            onPressed: () => notifier.refresh(),
          ),
        ],
      ),
      body: invitationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Iconify(Ph.warning_circle,
                    color: AppColors.lightMuted, size: 40),
                const SizedBox(height: 12),
                Text(
                  'Failed to load invitations',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => notifier.refresh(),
                  child: const Text('Tap to retry'),
                ),
              ],
            ),
          ),
        ),
        data: (invitations) {
          if (invitations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Iconify(Ph.envelope,
                      color: AppColors.lightMuted, size: 48),
                  const SizedBox(height: 12),
                  const Text(
                    'No invitations yet',
                    style: TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'When someone invites you to play,\nit will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: invitations.length,
            itemBuilder: (context, index) =>
                _InvitationCard(
                  invitation: invitations[index],
                  onAccept: () async {
                    final error = await notifier.respondToInvitation(
                        invitations[index].id, 'accepted');
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $error')),
                      );
                    }
                  },
                  onDecline: () async {
                    final error = await notifier.respondToInvitation(
                        invitations[index].id, 'declined');
                    if (error != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed: $error')),
                      );
                    }
                  },
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      Routes.invitationDetails,
                      arguments: invitations[index],
                    );
                  },
                ),
          );
        },
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final Invitation invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onTap;

  const _InvitationCard({
    required this.invitation,
    this.onAccept,
    this.onDecline,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPending = invitation.status == InvitationStatus.pending;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.lightBg,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Court image placeholder ──
              Container(
                height: 110,
                width: double.infinity,
                color: AppColors.lightField,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Iconify(Ph.tennis_ball,
                          color: AppColors.lightMuted, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        invitation.courtName.isNotEmpty
                            ? invitation.courtName
                            : 'Court',
                        style: const TextStyle(
                            color: AppColors.lightMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Body ──
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender row
                    Row(
                      children: [
                        // Sender avatar
                        Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.lightField,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person,
                              color: AppColors.lightMuted, size: 20),
                        ),
                        const SizedBox(width: 10),
                        // Sender ID
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sender',
                                style: const TextStyle(
                                    color: AppColors.lightText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                              const SizedBox(height: 1),
                              Text(
                                invitation.senderId.length > 12
                                    ? '@${invitation.senderId.substring(0, 12)}...'
                                    : '@${invitation.senderId}',
                                style: const TextStyle(
                                    color: AppColors.lightMuted,
                                    fontSize: 12)),
                            ],
                          ),
                        ),
                        // Status badge
                        _statusBadge(invitation.status),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Court name
                    Text(invitation.courtName,
                        style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),

                    // Date/time
                    Row(
                      children: [
                        const Iconify(Ph.clock,
                            color: AppColors.lightMuted, size: 14),
                        const SizedBox(width: 5),
                        Text(
                          '${invitation.date} · ${invitation.timeSlot}',
                          style: const TextStyle(
                              color: AppColors.lightMuted, fontSize: 12)),
                      ],
                    ),

                    // Message
                    if (invitation.message != null &&
                        invitation.message!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        invitation.message!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.lightMuted, fontSize: 12),
                      ),
                    ],

                    // ── Action buttons (only for pending) ──
                    if (isPending) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: onAccept,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.neonGreen,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text('Accept',
                                      style: TextStyle(
                                          color: AppColors.darkText,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: onDecline,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.lightField,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                  child: Text('Decline',
                                      style: TextStyle(
                                          color: AppColors.lightMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(InvitationStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case InvitationStatus.pending:
        bgColor = const Color(0xFFFFB800).withAlpha(25);
        textColor = const Color(0xFFFFB800);
        label = 'Pending';
      case InvitationStatus.accepted:
        bgColor = AppColors.neonGreen.withAlpha(25);
        textColor = AppColors.neonGreen;
        label = 'Accepted';
      case InvitationStatus.declined:
        bgColor = const Color(0xFFFF4D4F).withAlpha(25);
        textColor = const Color(0xFFFF4D4F);
        label = 'Declined';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: textColor.withAlpha(80), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}