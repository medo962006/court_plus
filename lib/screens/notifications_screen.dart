import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/supabase_provider.dart';
import '../services/models.dart';

// ─── Provider ───

final userNotificationsProvider = FutureProvider<List<NotificationItem>>((ref) async {
  final service = ref.read(supabaseServiceProvider);
  final result = await service.getUserNotifications();
  return result.fold(
    (notifications) => notifications,
    (_) => <NotificationItem>[],
  );
});

// ─── Screen ───

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  List<_DisplayNotification> _buildDisplayList(List<NotificationItem> items) {
    if (items.isEmpty) return const [];

    return items.map((n) {
      final createdAt = DateTime.tryParse(n.createdAt) ?? DateTime.now();
      return _DisplayNotification(
        handle: n.type,
        text: n.body ?? n.title ?? '',
        time: _formatRelativeTime(createdAt),
        badgeIcon: _iconForType(n.type),
        action: _actionForType(n.type),
        createdAt: createdAt,
      );
    }).toList();
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  String _iconForType(String type) {
    switch (type) {
      case 'follow':
        return Ph.user_plus_fill;
      case 'match_invite':
      case 'invite':
        return Ph.tennis_ball_fill;
      case 'booking':
      case 'booking_confirmed':
        return Ph.calendar_check_fill;
      case 'like':
      case 'moment_like':
        return Ph.heart_fill;
      default:
        return Ph.bell_fill;
    }
  }

  _ActionType _actionForType(String type) {
    switch (type) {
      case 'follow':
        return _ActionType.followBack;
      case 'match_invite':
      case 'invite':
        return _ActionType.accept;
      case 'booking':
      case 'booking_confirmed':
        return _ActionType.view;
      case 'like':
      case 'moment_like':
        return _ActionType.momentThumb;
      default:
        return _ActionType.view;
    }
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(userNotificationsProvider);

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
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Iconify(Ph.warning_circle, size: 40, color: AppColors.lightMuted),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load notifications',
                    style: TextStyle(color: Colors.grey[600], fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => ref.invalidate(userNotificationsProvider),
                    child: const Text('Tap to retry'),
                  ),
                ],
              ),
            ),
          );
        },
        data: (items) {
          final displayList = _buildDisplayList(items);
          return _buildListView(displayList);
        },
      ),
    );
  }

  Widget _buildListView(List<_DisplayNotification> notifications) {
    final today = <_DisplayNotification>[];
    final yesterday = <_DisplayNotification>[];
    final earlier = <_DisplayNotification>[];
    final now = DateTime.now();

    for (final n in notifications) {
      final diff = now.difference(n.createdAt);
      if (diff.inDays == 0) {
        today.add(n);
      } else if (diff.inDays == 1) {
        yesterday.add(n);
      } else {
        earlier.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        if (today.isNotEmpty) ...[
          const _SectionHeader('Today'),
          ...today.map((n) => _NotificationTile(
                handle: n.handle,
                text: n.text,
                time: n.time,
                badgeIcon: n.badgeIcon,
                action: n.action,
              )),
        ],
        if (yesterday.isNotEmpty) ...[
          const _SectionHeader('Yesterday'),
          ...yesterday.map((n) => _NotificationTile(
                handle: n.handle,
                text: n.text,
                time: n.time,
                badgeIcon: n.badgeIcon,
                action: n.action,
              )),
        ],
        if (earlier.isNotEmpty) ...[
          const _SectionHeader('Earlier'),
          ...earlier.map((n) => _NotificationTile(
                handle: n.handle,
                text: n.text,
                time: n.time,
                badgeIcon: n.badgeIcon,
                action: n.action,
              )),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

// ─── Internal data model ───

class _DisplayNotification {
  final String handle, text, time, badgeIcon;
  final _ActionType action;
  final DateTime createdAt;

  const _DisplayNotification({
    required this.handle,
    required this.text,
    required this.time,
    required this.badgeIcon,
    required this.action,
    required this.createdAt,
  });
}

// ─── UI widgets ───

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