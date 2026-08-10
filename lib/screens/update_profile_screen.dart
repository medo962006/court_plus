import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../services/image_service.dart';
import '../services/supabase_service.dart';
import '../presentation/providers/auth_provider.dart';
import '../l10n/app_strings.dart';

class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  String? _avatarUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authStateProvider).user;
      if (user != null) {
        _nameCtrl.text = user.fullName;
        _usernameCtrl.text = user.username;
        _phoneCtrl.text = user.phone ?? '';
        _bioCtrl.text = user.bio ?? '';
        _dobCtrl.text = user.dateOfBirth ?? '';
        setState(() => _avatarUrl = user.avatarUrl);
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final user = ref.read(authStateProvider).user;
    if (user == null) return;
    final url = await ImageService().pickAndUploadImage(
      bucket: 'avatars',
      userId: user.id,
    );
    if (url != null && mounted) {
      setState(() => _avatarUrl = url);
    }
  }

  Future<void> _save() async {
    final user = ref.read(authStateProvider).user;
    if (user == null) return;

    setState(() => _isSaving = true);

    final updates = <String, dynamic>{
      'full_name': _nameCtrl.text.trim(),
      'username': _usernameCtrl.text.trim(),
      'phone': _phoneCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'date_of_birth': _dobCtrl.text.trim(),
      if (_avatarUrl != null) 'avatar_url': _avatarUrl,
    };

    final result = await SupabaseService().updateProfile(user.id, updates);
    result.fold(
      (_) {
        ref.read(authStateProvider.notifier).updateProfile(user.copyWith(
          fullName: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          bio: _bioCtrl.text.trim(),
          dateOfBirth: _dobCtrl.text.trim(),
          avatarUrl: _avatarUrl,
        ));
        if (mounted) Navigator.of(context).pop();
      },
      (e) {
        if (mounted) {
          setState(() => _isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: Colors.red),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context).t;

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
        title: Text(t('updateProfile'),
            style: const TextStyle(color: AppColors.lightText, fontSize: 17, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(t('save'), style: const TextStyle(color: AppColors.neonGreen, fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar section
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.lightField,
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, size: 50, color: AppColors.lightMuted)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: AppColors.neonGreen,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt, size: 18, color: AppColors.darkText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildField(t('fullName'), _nameCtrl, hint: t('enterFullName')),
            const SizedBox(height: 16),
            _buildField(t('username'), _usernameCtrl, hint: t('usernameHint')),
            const SizedBox(height: 16),
            _buildField(t('bio'), _bioCtrl, hint: t('tellUsAboutYourself'), maxLines: 3),
            const SizedBox(height: 16),
            _buildField(t('phoneNumber'), _phoneCtrl, hint: t('phoneHint'), keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildField(t('dateOfBirth'), _dobCtrl, hint: t('dobHint')),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.lightMuted, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.lightField,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.lightText, fontSize: 15),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.lightMuted, fontSize: 14),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }
}