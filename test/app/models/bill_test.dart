import 'package:bs_flutter/app/models/bill.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Bill Model Tests', () {
    test('Bill serialization and deserialization', () {
      final billItem = BillItem(name: 'Pizza', price: 10.0, quantity: 2, consumedBy: ['Alice', 'Bob']);

      final bill = Bill(
        id: '1',
        paidBy: 'Alice',
        amount: 25.0,
        tax: 2.5,
        service: 3.0,
        items: [billItem],
        createdAt: DateTime(2023, 1, 1),
      );

      final json = bill.toJson();
      final deserialized = Bill.fromJson(json);

      expect(deserialized.id, bill.id);
      expect(deserialized.paidBy, bill.paidBy);
      expect(deserialized.amount, bill.amount);
      expect(deserialized.tax, bill.tax);
      expect(deserialized.service, bill.service);
      expect(deserialized.items.length, bill.items.length);
      expect(deserialized.items[0].name, billItem.name);
      expect(deserialized.createdAt, bill.createdAt);
    });

    test('BillItem serialization and deserialization', () {
      final billItem = BillItem(name: 'Burger', price: 5.0, quantity: 1, consumedBy: ['Charlie']);

      final json = billItem.toJson();
      final deserialized = BillItem.fromJson(json);

      expect(deserialized.name, billItem.name);
      expect(deserialized.price, billItem.price);
      expect(deserialized.quantity, billItem.quantity);
      expect(deserialized.consumedBy, billItem.consumedBy);
    });
  });
}
