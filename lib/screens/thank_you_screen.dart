import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class ThankYouScreen extends StatelessWidget {
  const ThankYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            // Success circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  size: 72,
                  color: AppColors.neonGreen,
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Thank You!',
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your review has been submitted\nsuccessfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.lightMuted,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.activity,
                        (route) => route.isFirst,
                      ),
                  child: const Text('OK, Continue'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}