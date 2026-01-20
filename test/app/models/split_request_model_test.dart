import 'package:bs_flutter/app/models/split_request/split_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplitRequestModel Tests', () {
    test('SplitRequest serialization and deserialization', () {
      final splitItem = SplitItem(name: 'Pizza', price: 10.0, quantity: 2, consumedBy: ['Alice', 'Bob']);
      final splitBill = SplitBill(items: [splitItem], paidBy: 'Alice', amountPaid: 25.0, taxRate: 0.08, serviceCharge: 0.05);
      final splitRequest = SplitRequest(bills: [splitBill]);

      final json = splitRequest.toJson();
      final deserialized = SplitRequest.fromJson(json);

      expect(deserialized.bills.length, 1);
      expect(deserialized.bills[0].paidBy, 'Alice');
      expect(deserialized.bills[0].items[0].name, 'Pizza');
    });

    test('SplitRequest equality', () {
      final item1 = SplitItem(name: 'Burger', price: 5.0, quantity: 1, consumedBy: ['Charlie']);
      final bill1 = SplitBill(items: [item1], paidBy: 'Charlie', amountPaid: 5.0, taxRate: 0.0, serviceCharge: 0.0);
      final request1 = SplitRequest(bills: [bill1]);

      final item2 = SplitItem(name: 'Burger', price: 5.0, quantity: 1, consumedBy: ['Charlie']);
      final bill2 = SplitBill(items: [item2], paidBy: 'Charlie', amountPaid: 5.0, taxRate: 0.0, serviceCharge: 0.0);
      final request2 = SplitRequest(bills: [bill2]);

      expect(request1, request2);
    });
  });
}
