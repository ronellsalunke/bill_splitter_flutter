import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';

class Utility {
  static Future<File?> pickImage(BuildContext context, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 50, // Compress for OCR
      );

      if (pickedFile == null) return null;

      final file = File(pickedFile.path);

      // Basic validation
      if (!await file.exists()) return null;
      if (await file.length() > 10 * 1024 * 1024) {
        // 10MB limit
        return null; // Too large
      }

      return file;
    } catch (e) {
      return null;
    }
  }
}
