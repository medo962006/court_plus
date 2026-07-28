import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

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
        title: const Text('Settings',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          const _SettingsTile(
            icon: Ph.user_circle,
            title: 'Account',
          ),
          const _SettingsTile(
            icon: Ph.translate,
            title: 'Language',
            trailing: 'English',
          ),
          _SettingsSwitchTile(
            icon: Ph.bell,
            title: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (val) =>
                setState(() => _notificationsEnabled = val),
          ),
          const _SettingsTile(
            icon: Ph.credit_card,
            title: 'Payment methods',
          ),
          const _SettingsTile(
            icon: Ph.lock_simple,
            title: 'Privacy',
          ),
          const _SettingsTile(
            icon: Ph.info,
            title: 'About',
          ),
          const SizedBox(height: 16),
          // ── Logout ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: ListTile(
              leading: const Iconify(Ph.sign_out,
                  size: 22, color: AppColors.error),
              title: const Text('Logout',
                  style: TextStyle(
                      color: AppColors.error,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              trailing: const Iconify(Ph.caret_right,
                  size: 16, color: AppColors.lightMuted),
              onTap: () => _showLogoutDialog(context),
            ),
          ),
          const SizedBox(height: 32),
          // ── App version ──
          Center(
            child: Text('Version 1.0.0',
                style: TextStyle(
                    color: AppColors.lightMuted, fontSize: 12)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout',
            style: TextStyle(color: AppColors.lightText)),
        content: const Text('Are you sure you want to logout?',
            style: TextStyle(color: AppColors.lightMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.lightMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.login, (_) => false);
            },
            child: const Text('Logout',
                style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String icon, title;
  final String? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: ListTile(
        leading: Iconify(icon, size: 22, color: AppColors.lightText),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.lightText,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        trailing: trailing != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trailing!,
                      style: const TextStyle(
                          color: AppColors.lightMuted, fontSize: 14)),
                  const SizedBox(width: 6),
                  const Iconify(Ph.caret_right,
                      size: 16, color: AppColors.lightMuted),
                ],
              )
            : const Iconify(Ph.caret_right,
                size: 16, color: AppColors.lightMuted),
        onTap: () {
          if (title == 'Language') {
            Navigator.of(context).pushNamed(Routes.language);
          }
        },
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final String icon, title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: ListTile(
        leading: Iconify(icon, size: 22, color: AppColors.lightText),
        title: Text(title,
            style: const TextStyle(
                color: AppColors.lightText,
                fontSize: 15,
                fontWeight: FontWeight.w500)),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: AppColors.neonGreen,
          activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}