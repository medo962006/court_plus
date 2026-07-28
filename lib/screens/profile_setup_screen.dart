import 'package:flutter/material.dart';
import '../routes.dart';
import '../theme/app_theme.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final TextEditingController _bioController = TextEditingController();
  int _bioLength = 0;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(
        () => setState(() => _bioLength = _bioController.text.length));
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacementNamed(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Complete Your\nProfile Setup',
                      style: TextStyle(
                        color: AppColors.lightText,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Header image upload + avatar
                    SizedBox(
                      height: 170,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            height: 130,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.lightField,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE1E4E8)),
                            ),
                            child: const Center(
                              child: Icon(Icons.camera_alt_outlined,
                                  color: AppColors.lightMuted, size: 32),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 20,
                            child: Stack(
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightField,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 4),
                                  ),
                                  child: const Icon(Icons.person_outline,
                                      color: AppColors.lightMuted, size: 36),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: AppColors.neonGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.camera_alt,
                                        size: 15,
                                        color: AppColors.lightText),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const _LightLabel('Full Name'),
                    const _LightField(hint: 'Your name'),
                    const SizedBox(height: 16),
                    const _LightLabel('Username'),
                    const _LightField(hint: '@username'),
                    const SizedBox(height: 16),
                    const _LightLabel('Bio'),
                    Container(
                      decoration: _fieldDecoration(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _bioController,
                            maxLines: 3,
                            maxLength: 120,
                            style: const TextStyle(
                                color: AppColors.lightText, fontSize: 15),
                            decoration: const InputDecoration(
                              hintText: 'Tell us about yourself…',
                              hintStyle: TextStyle(
                                  color: AppColors.lightMuted, fontSize: 14),
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(right: 12, bottom: 8),
                            child: Text(
                              '$_bioLength/120',
                              style: const TextStyle(
                                  color: AppColors.lightMuted, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _LightLabel('Sports level'),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add,
                          color: AppColors.lightText, size: 20),
                      label: const Text(
                        'Add Game',
                        style: TextStyle(
                            color: AppColors.lightText,
                            fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        side: const BorderSide(color: Color(0xFFE1E4E8)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Footer buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _finish,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(54),
                        side: const BorderSide(color: Color(0xFFE1E4E8)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Skip',
                          style: TextStyle(
                              color: AppColors.lightText,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _finish,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightText,
                        minimumSize: const Size.fromHeight(54),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Done',
                          style: TextStyle(
                              color: AppColors.neonGreen,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _fieldDecoration() => BoxDecoration(
        color: AppColors.lightField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      );
}

class _LightLabel extends StatelessWidget {
  final String text;
  const _LightLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              color: AppColors.lightMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _LightField extends StatelessWidget {
  final String hint;
  const _LightField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: TextField(
        style: const TextStyle(color: AppColors.lightText, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              const TextStyle(color: AppColors.lightMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
      ),
    );
  }
}