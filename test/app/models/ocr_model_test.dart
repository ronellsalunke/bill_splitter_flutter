import 'package:bs_flutter/app/models/ocr/ocr_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OcrModel Tests', () {
    test('OcrModel serialization and deserialization', () {
      final items = Items(name: 'Coffee', price: 3.0, quantity: 1);
      final ocrModel = OcrModel(items: [items], taxRate: 0.08, serviceCharge: 0.05, amountPaid: 25.0);

      final json = ocrModel.toJson();
      final deserialized = OcrModel.fromJson(json);

      expect(deserialized.items!.length, 1);
      expect(deserialized.items![0]!.name, 'Coffee');
      expect(deserialized.taxRate, 0.08);
      expect(deserialized.serviceCharge, 0.05);
      expect(deserialized.amountPaid, 25.0);
    });

    test('OcrModel copyWith', () {
      final original = OcrModel(items: []);
      final copied = original.copyWith(taxRate: 0.1);

      expect(copied.taxRate, 0.1);
    });

    test('OcrModel equality', () {
      final model1 = OcrModel(items: [Items(name: 'Tea', price: 2.0, quantity: 1)], taxRate: 0.05);
      final model2 = OcrModel(items: [Items(name: 'Tea', price: 2.0, quantity: 1)], taxRate: 0.05);

      expect(model1, model2);
    });
  });
}
