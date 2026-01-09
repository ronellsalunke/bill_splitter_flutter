import 'dart:io';

import 'package:bs_flutter/app/data/endpoints.dart';
import 'package:bs_flutter/app/data/base_api_services.dart';
import 'package:bs_flutter/app/data/network_api_service.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:dio/dio.dart';

class AppRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<OcrModel> processReceipt(File image) async {
    try {
      final url = Endpoints.ocr;
      final formData = FormData.fromMap({'file': await MultipartFile.fromFile(image.path, filename: 'receipt.jpg')});
      dynamic response = await _apiServices.getPostApiResponse(url, formData);
      return OcrModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
