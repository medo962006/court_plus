import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

enum _InvitationStatus { pending, accepted, declined }

class _InvitationData {
  final String senderName, senderHandle, courtName, dateTime, courtInitials;
  final _InvitationStatus status;

  const _InvitationData({
    required this.senderName,
    required this.senderHandle,
    required this.courtName,
    required this.dateTime,
    required this.courtInitials,
    required this.status,
  });
}

class ReceiveInvitationScreen extends StatelessWidget {
  const ReceiveInvitationScreen({super.key});

  static const _invitations = [
    _InvitationData(
      senderName: 'Levi Leon',
      senderHandle: 'levilleon',
      courtName: 'Court A - Tennis',
      dateTime: 'Today, 18:00',
      courtInitials: 'A',
      status: _InvitationStatus.pending,
    ),
    _InvitationData(
      senderName: 'Hafez S.',
      senderHandle: 'Hafezs',
      courtName: 'Court B - Padel',
      dateTime: 'Tomorrow, 20:00',
      courtInitials: 'B',
      status: _InvitationStatus.pending,
    ),
    _InvitationData(
      senderName: 'Sara M.',
      senderHandle: 'sara_m',
      courtName: 'Court C - Tennis',
      dateTime: 'Fri, 16:30',
      courtInitials: 'C',
      status: _InvitationStatus.accepted,
    ),
    _InvitationData(
      senderName: 'Khaled A.',
      senderHandle: 'khaled9',
      courtName: 'Court D - Tennis',
      dateTime: 'Sat, 09:00',
      courtInitials: 'D',
      status: _InvitationStatus.declined,
    ),
    _InvitationData(
      senderName: 'Mohammed Ahmed',
      senderHandle: 'm_ahmed',
      courtName: 'Court E - Padel',
      dateTime: 'Sat, 14:00',
      courtInitials: 'E',
      status: _InvitationStatus.pending,
    ),
  ];

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
        title: const Text('Invitations',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: _invitations.length,
        itemBuilder: (context, index) =>
            _InvitationCard(data: _invitations[index]),
      ),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final _InvitationData data;

  const _InvitationCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
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
                    Text('Court ${data.courtInitials}',
                        style: const TextStyle(
                            color: AppColors.lightMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
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
                      // Sender name + handle
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data.senderName,
                                style: const TextStyle(
                                    color: AppColors.lightText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 1),
                            Text('@${data.senderHandle}',
                                style: const TextStyle(
                                    color: AppColors.lightMuted,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                      // Status badge
                      _statusBadge(data.status),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Court name
                  Text(data.courtName,
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
                      Text(data.dateTime,
                          style: const TextStyle(
                              color: AppColors.lightMuted, fontSize: 12)),
                    ],
                  ),

                  // ── Action buttons (only for pending) ──
                  if (data.status == _InvitationStatus.pending) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              // Accept action
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                            onTap: () {
                              // Decline action
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _statusBadge(_InvitationStatus status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case _InvitationStatus.pending:
        bgColor = const Color(0xFFFFB800).withAlpha(25);
        textColor = const Color(0xFFFFB800);
        label = 'Pending';
      case _InvitationStatus.accepted:
        bgColor = AppColors.neonGreen.withAlpha(25);
        textColor = AppColors.neonGreen;
        label = 'Accepted';
      case _InvitationStatus.declined:
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