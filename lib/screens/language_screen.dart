import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_theme.dart';
import '../widgets/court_plus_logo.dart';
import '../widgets/country_flag.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  int _selected = 1; // 0 = Arabic, 1 = English

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Center(child: CourtPlusLogo(height: 34)),
              const Spacer(),
              const Text(
                'Choose Your language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 32),
              _LanguageCard(
                label: 'Arabic',
                flagCode: 'sa',
                selected: _selected == 0,
                onTap: () => setState(() => _selected = 0),
              ),
              const SizedBox(height: 16),
              _LanguageCard(
                label: 'English',
                flagCode: 'gb',
                selected: _selected == 1,
                onTap: () => setState(() => _selected = 1),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(Routes.onboarding),
                child: const Text('Done'),
              ),
              const SizedBox(height: 16),
              const Text(
                'By continuing you agree to our Terms of Service\nand Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.white60, fontSize: 12),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String label;
  final String flagCode;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.label,
    required this.flagCode,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonGreen.withValues(alpha: 0.12)
              : AppColors.darkField,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.neonGreen : AppColors.darkBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            CountryFlag(code: flagCode, width: 30),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.neonGreen : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle,
                  color: AppColors.neonGreen, size: 24),
          ],
        ),
      ),
    );
  }
}