import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../presentation/providers/settings_provider.dart';

/// Notification preference toggles matching the Court+ App Workflows PDF.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  static const _items = [
    (Ph.heart, 'Likes'),
    (Ph.user_plus, 'New followers'),
    (Ph.tennis_ball, 'Open match'),
    (Ph.chart_bar, 'Match activity'),
    (Ph.map_pin, 'Nearby courts'),
    (Ph.arrows_clockwise, 'Updates & more'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(notificationPrefsProvider);

    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22),
          color: AppColors.lightText,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Done',
              style: TextStyle(color: AppColors.lightText, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                ...List.generate(_items.length, (i) {
                  final icon = _items[i].$1;
                  final label = _items[i].$2;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.lightBorder),
                      ),
                      child: ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.lightField,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Iconify(icon, size: 20, color: AppColors.lightText),
                        ),
                        title: Text(label,
                            style: const TextStyle(
                                color: AppColors.lightText,
                                fontSize: 15,
                                fontWeight: FontWeight.w500)),
                        trailing: Switch(
                          value: prefs[i],
                          onChanged: (v) =>
                              ref.read(notificationPrefsProvider.notifier).set(i, v),
                          activeThumbColor: AppColors.neonGreen,
                          activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.4),
                          inactiveThumbColor: AppColors.lightMuted,
                          inactiveTrackColor: AppColors.lightField,
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    'Get notified about activities, matches and courts near you.',
                    style: TextStyle(color: AppColors.lightMuted, fontSize: 13, height: 1.4),
                  ),
                ),
              ],
            ),
    );
  }
}