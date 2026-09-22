import 'dart:io';

import 'package:bs_flutter/app/data/api_client.dart';
import 'package:bs_flutter/app/data/api_failure.dart';
import 'package:bs_flutter/app/data/endpoints.dart';
import 'package:bs_flutter/app/data/result.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/app/models/split_request/split_request_model.dart';
import 'package:bs_flutter/app/models/update/update_manifest.dart';

class AppRepository {
  AppRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<Result<OcrModel, ApiFailure>> processReceipt(File image) {
    return _guard(() async {
      final response = await _apiClient.uploadFile(Endpoints.ocr, field: 'file', file: image, filename: 'receipt.jpg');
      return _parse(() => OcrModel.fromJson(response as Map<String, dynamic>));
    });
  }

  Future<Result<SplitModel, ApiFailure>> calculateSplit(List<Bill> bills) {
    return _guard(() async {
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
      final response = await _apiClient.postJson(Endpoints.split, data);
      return _parse(() => SplitModel.fromJson(response as Map<String, dynamic>));
    });
  }

  Future<Result<UpdateManifest, ApiFailure>> fetchUpdateManifest() {
    return _guard(() async {
      final response = await _apiClient.getJson(Endpoints.updateManifest);
      return _parse(() => UpdateManifest.fromJson(response as Map<String, dynamic>));
    });
  }

  Future<Result<T, ApiFailure>> _guard<T>(Future<T> Function() action) async {
    try {
      return Success(await action());
    } on ApiFailure catch (error) {
      return FailureResult(error);
    } catch (error) {
      return FailureResult(ApiFailure(ApiFailureKind.unknown, error.toString()));
    }
  }

  T _parse<T>(T Function() parser) {
    try {
      return parser();
    } on ApiFailure {
      rethrow;
    } catch (error) {
      throw ApiFailure(ApiFailureKind.parsing, error.toString());
    }
  }
}
