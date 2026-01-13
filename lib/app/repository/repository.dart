import 'dart:io';

import 'package:bs_flutter/app/data/base_api_services.dart';
import 'package:bs_flutter/app/data/endpoints.dart';
import 'package:bs_flutter/app/data/network_api_service.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/app/models/split_request/split_request_model.dart';
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

  Future<SplitModel> calculateSplit(List<Bill> bills) async {
    try {
      final url = Endpoints.split;
      final splitRequest = SplitRequest(
        bills: bills
            .map(
              (bill) => SplitBill(
                items: bill.items
                    .map(
                      (item) =>
                          SplitItem(name: item.name, price: item.price, quantity: item.quantity, consumedBy: item.consumedBy),
                    )
                    .toList(),
                paidBy: bill.paidBy,
                amountPaid: bill.amount,
                taxRate: bill.tax / 100,
                serviceCharge: bill.service / 100,
              ),
            )
            .toList(),
      );
      final data = splitRequest.toJson();
      dynamic response = await _apiServices.getPostApiResponse(url, data);
      return SplitModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
