import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../widgets/country_flag.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Justin Nurmagomedov');
  final TextEditingController _usernameController =
      TextEditingController(text: 'justinnurmagomedov');
  final TextEditingController _phoneController =
      TextEditingController(text: '+44 7700 123456');
  final TextEditingController _bioController = TextEditingController(
      text: 'Professional athlete & sports enthusiast. Love competing and exploring new courts around the world.');
  final TextEditingController _dobController =
      TextEditingController(text: '15/03/1995');

  String _selectedGender = 'Male';
  int _bioLength = 0;

  @override
  void initState() {
    super.initState();
    _bioController.addListener(
        () => setState(() => _bioLength = _bioController.text.length));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop();
  }

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
        title: const Text(
          'Update Profile',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppColors.lightText,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Banner + Profile Pic ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                height: 170,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Banner image with camera+plus overlay
                    Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightField,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE1E4E8)),
                      ),
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            shape: BoxShape.circle,
                          ),
                          child: Iconify(
                            Ph.camera,
                            size: 22,
                            color: AppColors.lightText,
                          ),
                        ),
                      ),
                    ),
                    // Profile pic overlapping banner
                    Positioned(
                      bottom: 0,
                      left: 20,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white,
                            child: CircleAvatar(
                              radius: 39,
                              backgroundColor: AppColors.lightField,
                              child: const Icon(
                                Icons.person_outline,
                                color: AppColors.lightMuted,
                                size: 36,
                              ),
                            ),
                          ),
                          // Camera+plus overlay on avatar
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
                              child: Iconify(
                                Ph.camera,
                                size: 14,
                                color: AppColors.lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Form Card ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Full Name ──
                  const _FormLabel(text: 'Full name'),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: 'Full name',
                    prefixIcon: Ph.user,
                  ),
                  const SizedBox(height: 20),

                  // ── User Name ──
                  const _FormLabel(text: 'User name'),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _usernameController,
                    hint: 'User name',
                    prefixIcon: Ph.at,
                    suffixIcon: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Iconify(
                        Ph.check,
                        size: 13,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Mobile Number ──
                  const _FormLabel(text: 'Mobile number'),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _phoneController,
                    hint: 'Mobile number',
                    prefixIcon: Ph.device_mobile,
                    prefixWidget: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CountryFlag(code: 'gb', width: 20),
                          const SizedBox(width: 4),
                          const Text(
                            '+44',
                            style: TextStyle(
                              color: AppColors.lightText,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    suffixIcon: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                      ),
                      child: const Iconify(
                        Ph.check,
                        size: 13,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Date of Birth + Gender side by side ──
                  Row(
                    children: [
                      // Date of Birth
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel(text: 'Date of Birth'),
                            const SizedBox(height: 8),
                            _FormField(
                              controller: _dobController,
                              hint: 'DD/MM/YYYY',
                              prefixIcon: Ph.calendar_blank,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Gender
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _FormLabel(text: 'Gender'),
                            const SizedBox(height: 8),
                            Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: AppColors.lightField,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE1E4E8)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _selectedGender,
                                  style: const TextStyle(
                                    color: AppColors.lightText,
                                    fontSize: 15,
                                  ),
                                  dropdownColor: Colors.white,
                                  items: const [
                                    DropdownMenuItem(
                                        value: 'Male', child: Text('Male')),
                                    DropdownMenuItem(
                                        value: 'Female', child: Text('Female')),
                                    DropdownMenuItem(
                                        value: 'Prefer not to say',
                                        child: Text('Prefer not to say')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      setState(() => _selectedGender = value);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Bio ──
                  const _FormLabel(text: 'Bio'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.lightField,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE1E4E8)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextField(
                          controller: _bioController,
                          maxLines: 4,
                          maxLength: 140,
                          style: const TextStyle(
                            color: AppColors.lightText,
                            fontSize: 15,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Tell us about yourself…',
                            hintStyle: TextStyle(
                              color: AppColors.lightMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12, bottom: 8),
                          child: Text(
                            '$_bioLength/140',
                            style: const TextStyle(
                              color: AppColors.lightMuted,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Sports Level Section ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sports level',
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── Tennis sport level row ──
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.lightField,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE1E4E8)),
                    ),
                    child: Row(
                      children: [
                        // Racket icon + Tennis label
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Iconify(
                            Ph.tennis_ball_fill,
                            size: 18,
                            color: AppColors.lightText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Tennis',
                          style: TextStyle(
                            color: AppColors.lightText,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.neonGreen.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Beginner',
                            style: TextStyle(
                              color: AppColors.darkText,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.lightBorder),
                          ),
                          child: const Iconify(
                            Ph.pencil_simple,
                            size: 13,
                            color: AppColors.lightText,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ── + Add Game button ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Iconify(Ph.plus, size: 18),
                      label: const Text('Add Game'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lightText,
                        side: BorderSide(
                          color: AppColors.lightBorder,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.lightMuted,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final String? prefixIcon;
  final Widget? prefixWidget;
  final Widget? suffixIcon;

  const _FormField({
    this.controller,
    required this.hint,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.lightField,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE1E4E8)),
      ),
      child: Row(
        children: [
          if (prefixWidget != null)
            prefixWidget!
          else if (prefixIcon != null)
            Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Iconify(
                prefixIcon!,
                size: 18,
                color: AppColors.lightMuted,
              ),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: AppColors.lightText,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppColors.lightMuted,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                isDense: true,
              ),
            ),
          ),
          if (suffixIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: suffixIcon,
            ),
        ],
      ),
    );
  }
}