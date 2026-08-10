import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ph.dart';
import '../theme/app_theme.dart';
import '../services/image_service.dart';
import '../presentation/providers/auth_provider.dart';
import '../presentation/providers/supabase_provider.dart';

class CreateMomentScreen extends ConsumerStatefulWidget {
  const CreateMomentScreen({super.key});

  @override
  ConsumerState<CreateMomentScreen> createState() => _CreateMomentScreenState();
}

class _CreateMomentScreenState extends ConsumerState<CreateMomentScreen> {
  final ImageService _imageService = ImageService();
  final TextEditingController _captionController = TextEditingController();

  String? _imageUrl;
  bool _isUploading = false;
  bool _isPublishing = false;
  String? _error;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);
    final user = ref.read(authStateProvider).user;
    if (user == null) {
      setState(() {
        _isUploading = false;
        _error = 'User not authenticated';
      });
      return;
    }

    final url = await _imageService.pickAndUploadImage(
      bucket: 'moments',
      userId: user.id,
    );

    if (mounted) {
      setState(() {
        _isUploading = false;
        if (url != null) {
          _imageUrl = url;
          _error = null;
        }
      });
    }
  }

  Future<void> _publish() async {
    if (_imageUrl == null) {
      setState(() => _error = 'Please select an image first');
      return;
    }

    setState(() {
      _isPublishing = true;
      _error = null;
    });

    final supabase = ref.read(supabaseServiceProvider);
    final data = <String, dynamic>{
      'image_url': _imageUrl,
    };
    if (_captionController.text.trim().isNotEmpty) {
      data['caption'] = _captionController.text.trim();
    }

    final result = await supabase.createMoment(data);

    if (mounted) {
      result.fold(
        (_) => Navigator.of(context).pop(true),
        (err) => setState(() {
          _isPublishing = false;
          _error = err.message;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Create Moment',
          style: TextStyle(
            color: AppColors.lightText,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          _isPublishing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.lightText,
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _imageUrl != null ? _publish : null,
                  child: Text(
                    'Publish',
                    style: TextStyle(
                      color: _imageUrl != null
                          ? AppColors.lightText
                          : AppColors.lightMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, size: 18, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _error = null),
                      child: const Icon(Icons.close, size: 16, color: Colors.red),
                    ),
                  ],
                ),
              ),

            // Image picker area
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 260,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.lightField,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.lightBorder),
                  image: _imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(_imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _imageUrl == null
                    ? Center(
                        child: _isUploading
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 32,
                                    height: 32,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.lightText,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Uploading...',
                                    style: TextStyle(
                                      color: AppColors.lightMuted,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Iconify(
                                      Ph.camera,
                                      size: 28,
                                      color: AppColors.lightText,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Tap to add a photo',
                                    style: TextStyle(
                                      color: AppColors.lightMuted,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 20),

            // Caption field
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.lightBorder),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Caption',
                    style: TextStyle(
                      color: AppColors.lightMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _captionController,
                    maxLines: 3,
                    maxLength: 200,
                    style: const TextStyle(
                      color: AppColors.lightText,
                      fontSize: 15,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'What\'s on your mind…',
                      hintStyle: TextStyle(
                        color: AppColors.lightMuted,
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_captionController.text.length}/200',
                      style: const TextStyle(
                        color: AppColors.lightMuted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Publish button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _imageUrl != null && !_isPublishing ? _publish : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.lightField,
                  disabledForegroundColor: AppColors.lightMuted,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _isPublishing ? 'Publishing...' : 'Publish Moment',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}