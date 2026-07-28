import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Alex Rivera');
  final TextEditingController _usernameController =
      TextEditingController(text: 'alexrivera');
  final TextEditingController _bioController =
      TextEditingController(text: 'Love the game. Tennis & padel enthusiast 🎾');
  final TextEditingController _phoneController =
      TextEditingController(text: '+966 50 123 4567');
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
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _save() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBg,
      appBar: AppBar(
        backgroundColor: AppColors.lightBg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Iconify(Ph.x, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(
                color: AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header image + avatar (same pattern as ProfileSetupScreen) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
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
                        border: Border.all(color: const Color(0xFFE1E4E8)),
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
            ),
            const SizedBox(height: 24),
            // ── Form fields ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                          maxLength: 140,
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
                            '$_bioLength/140',
                            style: const TextStyle(
                                color: AppColors.lightMuted, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _LightLabel('Phone'),
                  const _LightField(hint: '+966 50 123 4567'),
                  const SizedBox(height: 16),
                  const _LightLabel('Date of Birth'),
                  const _LightField(hint: 'DD/MM/YYYY'),
                  const SizedBox(height: 16),
                  const _LightLabel('Gender'),
                  Container(
                    decoration: _fieldDecoration(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: 'Male',
                        style: const TextStyle(
                            color: AppColors.lightText, fontSize: 15),
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
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // ── Save button ──
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightText,
                        minimumSize: const Size.fromHeight(54),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 32),
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