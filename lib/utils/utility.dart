import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Utility {
  static Future<bool> hasInternetConnection() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

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
