import 'dart:io';

import 'package:bs_flutter/app/data/network_api_service.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNetworkApiService extends Mock implements NetworkApiService {}

class MockFile extends Mock implements File {}

class MockMultipartFile extends Mock implements MultipartFile {}

void main() {
  late AppRepository repository;
  late MockNetworkApiService mockApiService;
  late MockFile mockFile;
  late MockMultipartFile mockMultipartFile;

  setUp(() {
    mockApiService = MockNetworkApiService();
    mockFile = MockFile();
    mockMultipartFile = MockMultipartFile();

    repository = AppRepository(apiServices: mockApiService, multipartFileFactory: (path, filename) async => mockMultipartFile);
  });

  group('AppRepository Tests', () {
    test('processReceipt success', () async {
      final mockResponse = {
        'items': [
          {'name': 'Coffee', 'price': 3.0, 'quantity': 1},
        ],
        'tax_rate': 0.08,
        'service_charge': 0.05,
        'amount_paid': 25.0,
      };

      when(() => mockFile.path).thenReturn('test_receipt.jpg');
      when(() => mockApiService.getPostApiResponse(any(), any())).thenAnswer((_) async => mockResponse);

      final result = await repository.processReceipt(mockFile);

      expect(result, isA<OcrModel>());
      expect(result.items!.first!.name, 'Coffee');
      verify(() => mockApiService.getPostApiResponse(any(), any())).called(1);
    });

    test('calculateSplit success', () async {
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
      when(() => mockApiService.getPostApiResponse(any(), any())).thenAnswer((_) async => mockResponse);

      final bills = [Bill(id: '1', paidBy: 'Alice', amount: 25.0, tax: 2.0, service: 1.0, items: [], createdAt: DateTime.now())];
      final result = await repository.calculateSplit(bills);

      expect(result, isA<SplitModel>());
      expect(result.paymentPlans!.first!.name, 'Plan 1');
      verify(() => mockApiService.getPostApiResponse(any(), any())).called(1);
    });

    test('processReceipt throws on error', () async {
      when(() => mockFile.path).thenReturn('test_receipt.jpg');
      when(() => mockApiService.getPostApiResponse(any(), any())).thenThrow(Exception('Network error'));

      expect(() => repository.processReceipt(mockFile), throwsA(isA<Exception>()));
    });
  });
}
