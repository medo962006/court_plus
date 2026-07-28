import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notification',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Iconify(Ph.dots_three_bold, size: 22),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          _SectionHeader('New'),
          _NotificationTile(
            handle: 'levilleon',
            text: 'started following you.',
            time: '34m',
            badgeIcon: Ph.user_plus_fill,
            action: _ActionType.followBack,
          ),
          _NotificationTile(
            handle: 'Hafezs',
            text: 'invite you to open match.',
            time: '1h',
            badgeIcon: Ph.tennis_ball_fill,
            action: _ActionType.accept,
          ),
          _SectionHeader('yesterday'),
          _NotificationTile(
            handle: 'eaglesport',
            text: 'confirmed your booking for Court A.',
            time: '1d',
            badgeIcon: Ph.calendar_check_fill,
            action: _ActionType.view,
          ),
          _NotificationTile(
            handle: 'sara_m',
            text: 'liked your Moment.',
            time: '1d',
            badgeIcon: Ph.heart_fill,
            action: _ActionType.momentThumb,
          ),
          _SectionHeader('Last 7 days'),
          _NotificationTile(
            handle: 'Hafezs',
            text: 'invite you to open match.',
            time: '2d',
            badgeIcon: Ph.tennis_ball_fill,
            action: _ActionType.accept,
          ),
          _NotificationTile(
            handle: 'khaled9',
            text: 'started following you.',
            time: '5d',
            badgeIcon: Ph.user_plus_fill,
            action: _ActionType.following,
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.lightText,
              fontSize: 15,
              fontWeight: FontWeight.w700)),
    );
  }
}

enum _ActionType { followBack, following, accept, view, momentThumb }

class _NotificationTile extends StatelessWidget {
  final String handle, text, time;
  final String badgeIcon;
  final _ActionType action;

  const _NotificationTile({
    required this.handle,
    required this.text,
    required this.time,
    required this.badgeIcon,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Avatar with badge
          // PLACEHOLDER: user avatar photo → assets/images/avatar_<handle>.jpg
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.lightField,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person,
                    color: AppColors.lightMuted, size: 24),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Iconify(badgeIcon, size: 9, color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: AppColors.lightText, fontSize: 13, height: 1.35),
                children: [
                  TextSpan(
                      text: '$handle ',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  TextSpan(text: '$text '),
                  TextSpan(
                      text: time,
                      style:
                          const TextStyle(color: AppColors.lightMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          _buildAction(),
        ],
      ),
    );
  }

  Widget _buildAction() {
    switch (action) {
      case _ActionType.followBack:
        return _pill('Follow back', dark: true);
      case _ActionType.following:
        return _pill('Following', dark: false);
      case _ActionType.accept:
        return _pill('Accept', dark: true);
      case _ActionType.view:
        return _pill('View', dark: true);
      case _ActionType.momentThumb:
        // PLACEHOLDER: moment thumbnail → assets/images/moment_thumb.jpg
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 42,
            height: 42,
            color: AppColors.lightField,
            child: const Icon(Icons.image_outlined,
                color: AppColors.lightMuted, size: 20),
          ),
        );
    }
  }

  Widget _pill(String label, {required bool dark}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkSlate : AppColors.lightField,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: dark ? AppColors.neonGreen : AppColors.lightMuted,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}