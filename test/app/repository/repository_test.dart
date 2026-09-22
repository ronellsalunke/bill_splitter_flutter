import 'dart:io';

import 'package:bs_flutter/app/data/api_client.dart';
import 'package:bs_flutter/app/data/api_failure.dart';
import 'package:bs_flutter/app/data/endpoints.dart';
import 'package:bs_flutter/app/data/result.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/app/models/update/update_manifest.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockApiClient extends Mock implements ApiClient {}

class MockFile extends Mock implements File {}

void main() {
  late AppRepository repository;
  late MockApiClient mockApiClient;
  late MockFile mockFile;

  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockFile = MockFile();
    repository = AppRepository(apiClient: mockApiClient);
  });

  group('AppRepository Tests', () {
    test('processReceipt returns parsed OCR data', () async {
      final mockResponse = {
        'items': [
          {'name': 'Coffee', 'price': 3.0, 'quantity': 1},
        ],
        'tax_rate': 0.08,
        'service_charge': 0.05,
        'amount_paid': 25.0,
      };
      when(
        () => mockApiClient.uploadFile(Endpoints.ocr, field: 'file', file: mockFile, filename: 'receipt.jpg'),
      ).thenAnswer((_) async => mockResponse);

      final result = await repository.processReceipt(mockFile);

      expect(result, isA<Success<OcrModel, ApiFailure>>());
      final model = (result as Success<OcrModel, ApiFailure>).value;
      expect(model.items!.first!.name, 'Coffee');
      verify(() => mockApiClient.uploadFile(Endpoints.ocr, field: 'file', file: mockFile, filename: 'receipt.jpg')).called(1);
    });

    test('calculateSplit returns parsed payment plans', () async {
      final mockResponse = {
        'payment_plans': [
          {
            'name': 'Plan 1',
            'payments': [
              {'to': 'Bob', 'amount': 15.0},
            ],
          },
        ],
      };
      when(() => mockApiClient.postJson(Endpoints.split, any())).thenAnswer((_) async => mockResponse);
      final bills = [Bill(id: '1', paidBy: 'Alice', amount: 25.0, tax: 2.0, service: 1.0, items: [], createdAt: DateTime.now())];

      final result = await repository.calculateSplit(bills);

      expect(result, isA<Success<SplitModel, ApiFailure>>());
      final model = (result as Success<SplitModel, ApiFailure>).value;
      expect(model.paymentPlans!.first!.name, 'Plan 1');
      verify(() => mockApiClient.postJson(Endpoints.split, any())).called(1);
    });

    test('fetchUpdateManifest returns parsed manifest', () async {
      final mockResponse = {
        'latestVersion': '1.0.8',
        'latestBuildNumber': 8,
        'message': 'Update available',
        'releases': [
          {
            'version': '1.0.8',
            'buildNumber': 8,
            'changes': ['new stuff'],
          },
        ],
      };
      when(() => mockApiClient.getJson(Endpoints.updateManifest)).thenAnswer((_) async => mockResponse);

      final result = await repository.fetchUpdateManifest();

      expect(result, isA<Success<UpdateManifest, ApiFailure>>());
      final manifest = (result as Success<UpdateManifest, ApiFailure>).value;
      expect(manifest.latestVersion, '1.0.8');
      expect(manifest.latestBuildNumber, 8);
      expect(manifest.message, 'Update available');
      expect(manifest.releases.single.changes, ['new stuff']);
      verify(() => mockApiClient.getJson(Endpoints.updateManifest)).called(1);
    });

    test('propagates an API failure as FailureResult', () async {
      const failure = ApiFailure(ApiFailureKind.network, 'Network error');
      when(
        () => mockApiClient.uploadFile(Endpoints.ocr, field: 'file', file: mockFile, filename: 'receipt.jpg'),
      ).thenThrow(failure);

      final result = await repository.processReceipt(mockFile);

      expect(result, isA<FailureResult<OcrModel, ApiFailure>>());
      expect((result as FailureResult<OcrModel, ApiFailure>).failure, same(failure));
    });
  });
}
