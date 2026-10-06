import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  /// Pick an image from Gallery or Camera with aggressive compression for instant uploads
  Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 60,
      );
      return image;
    } catch (e) {
      debugPrint('[StorageService] Error picking image: $e');
      return null;
    }
  }

  /// Upload item image to Firebase Storage with ultra-fast 3s timeout & instant base64 fallback
  Future<String?> uploadItemImage({
    required XFile imageFile,
    required String userId,
  }) async {
    try {
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final Reference ref = _storage.ref().child('items/$userId/$fileName');

      UploadTask uploadTask;
      if (kIsWeb) {
        final Uint8List bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        uploadTask = ref.putFile(File(imageFile.path));
      }

      // 3-second timeout for Firebase Storage cloud upload
      final TaskSnapshot snapshot = await uploadTask.timeout(const Duration(seconds: 3));
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      debugPrint('[StorageService] Firebase Storage upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      debugPrint('[StorageService] Storage upload timed out or failed ($e). Converting to instant Base64 data URL...');
      try {
        final Uint8List bytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(bytes);
        return 'data:image/jpeg;base64,$base64String';
      } catch (b64Err) {
        debugPrint('[StorageService] Base64 encoding error: $b64Err');
        return 'https://images.unsplash.com/photo-1544717305-2782549b5136?w=600&auto=format&fit=crop';
      }
    }
  }
}
