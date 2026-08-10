import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../routes.dart';
import '../widgets/country_flag.dart';
import '../l10n/app_strings.dart';

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
      backgroundColor: AppColors.lightSurface,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Iconify(Ph.arrow_left, size: 22),
          color: AppColors.lightText,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(AppStrings.of(context).t('settingsAndActivity'),
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          // ── Saved Card ──
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Iconify(Ph.bookmark_simple,
                    size: 20, color: AppColors.lightText),
              ),
              title: Text(AppStrings.of(context).t('saved'),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Iconify(Ph.caret_right,
                  size: 16, color: AppColors.lightMuted),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),

          // ── Settings Section Header ──
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8, bottom: 12),
            child: Text(AppStrings.of(context).t('settings'),
              style: TextStyle(
                color: AppColors.lightMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // ── Notifications ──
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Iconify(Ph.bell,
                    size: 20, color: AppColors.lightText),
              ),
              title: Text(AppStrings.of(context).t('notifications'),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (val) =>
                    setState(() => _notificationsEnabled = val),
                activeThumbColor: AppColors.neonGreen,
                activeTrackColor: AppColors.neonGreen.withValues(alpha: 0.4),
                inactiveThumbColor: AppColors.lightMuted,
                inactiveTrackColor: AppColors.lightField,
              ),
            ),
          ),
          const SizedBox(height: 2),

          // ── Language ──
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Iconify(Ph.globe,
                    size: 20, color: AppColors.lightText),
              ),
              title: Text(AppStrings.of(context).t('language'),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CountryFlag(code: 'gb', width: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'English',
                    style: TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Iconify(Ph.caret_right,
                      size: 16, color: AppColors.lightMuted),
                ],
              ),
              onTap: () => Navigator.of(context).pushNamed(Routes.language),
            ),
          ),
          const SizedBox(height: 2),

          // ── How Court+ work ──
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Iconify(Ph.question,
                    size: 20, color: AppColors.lightText),
              ),
              title: Text(AppStrings.of(context).t('howCourtPlusWorks'),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Iconify(Ph.caret_right,
                  size: 16, color: AppColors.lightMuted),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 20),

          // ── Legal Information Section Header ──
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8, bottom: 12),
            child: Text(AppStrings.of(context).t('legalInformation'),
              style: TextStyle(
                color: AppColors.lightMuted,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // ── Terms of use ──
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Iconify(Ph.file_text,
                    size: 20, color: AppColors.lightText),
              ),
              title: Text(AppStrings.of(context).t('termsOfUse'),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Iconify(Ph.caret_right,
                  size: 16, color: AppColors.lightMuted),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 2),

          // ── Privacy policy ──
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Iconify(Ph.eye,
                    size: 20, color: AppColors.lightText),
              ),
              title: Text(AppStrings.of(context).t('privacyPolicy'),
                style: TextStyle(
                  color: AppColors.lightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: const Iconify(Ph.caret_right,
                  size: 16, color: AppColors.lightMuted),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),

          // ── Log out ──
          _SettingsCard(
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Iconify(Ph.door,
                    size: 20, color: AppColors.error),
              ),
              title: Text(AppStrings.of(context).t('logOut'),
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Iconify(Ph.caret_right,
                  size: 16, color: AppColors.lightMuted),
              onTap: () => _showLogoutDialog(context),
            ),
          ),
          const SizedBox(height: 24),

          // ── App version ──
          Center(
            child: Text(
              AppStrings.of(context).t('version'),
              style: TextStyle(
                color: AppColors.lightMuted.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
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
        title: Text(AppStrings.of(context).t('logout'),
          style: TextStyle(color: AppColors.lightText),
        ),
        content: Text(AppStrings.of(context).t('areYouSureLogout'),
          style: TextStyle(color: AppColors.lightMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppStrings.of(context).t('cancel'),
              style: TextStyle(color: AppColors.lightMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(Routes.login, (_) => false);
            },
            child: Text(AppStrings.of(context).t('logout'),
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SettingsCard extends StatelessWidget {
  final Widget child;

  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: child,
    );
  }
}