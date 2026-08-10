import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/logger.dart';
import 'supabase_service.dart';

/// Service for picking images from gallery/camera and uploading to Supabase Storage.
class ImageService {
  final ImagePicker _picker = ImagePicker();
  final SupabaseService _supabase = SupabaseService();

  /// Pick an image from the gallery, compress it, upload to [bucket], and return the public URL.
  ///
  /// Path inside the bucket: `{userId}/{timestamp}_{random}.jpg`
  /// Returns `null` if the user cancels picking.
  Future<String?> pickAndUploadImage({
    required String bucket,
    required String userId,
  }) async {
    try {
      // 1. Pick image from gallery
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null) return null;

      // 2. Read bytes
      final bytes = await picked.readAsBytes();

      // 3. Determine extension
      final ext = picked.name.contains('.')
          ? picked.name.split('.').last.toLowerCase()
          : 'jpg';

      // 4. Build a unique path
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '$userId/${timestamp}_${userId.substring(0, 4)}.$ext';

      // 5. Upload to Supabase Storage
      await _supabase.client.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/$ext',
              upsert: true,
            ),
          );

      // 6. Get public URL
      final publicUrl = _supabase.client.storage.from(bucket).getPublicUrl(path);

      AppLogger.info('Image uploaded: $bucket/$path');
      return publicUrl;
    } on Exception catch (e) {
      AppLogger.error('Image pick/upload failed: $e');
      return null;
    }
  }

  /// Pick an image from the gallery and return the XFile (without uploading).
  /// Useful for preview before upload.
  Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );
    } on Exception catch (e) {
      AppLogger.error('Image pick failed: $e');
      return null;
    }
  }
}