import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Utility {
  static Future<Object> pickImg(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      // Pick an image.
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      File file = File(image?.path ?? '');
      return file;
    } catch (e) {
      return '';
    }
  }
}
