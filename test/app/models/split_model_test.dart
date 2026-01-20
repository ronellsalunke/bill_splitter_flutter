import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SplitModel Tests', () {
    test('SplitModel serialization and deserialization', () {
      final payments = Payments(to: 'Bob', amount: 15.0);
      final paymentPlans = PaymentPlans(name: 'Plan 1', payments: [payments]);
      final splitModel = SplitModel(paymentPlans: [paymentPlans]);

      final json = splitModel.toJson();
      final deserialized = SplitModel.fromJson(json);

      expect(deserialized.paymentPlans!.length, 1);
      expect(deserialized.paymentPlans![0]!.name, 'Plan 1');
      expect(deserialized.paymentPlans![0]!.payments![0]!.to, 'Bob');
      expect(deserialized.paymentPlans![0]!.payments![0]!.amount, 15.0);
    });

    test('SplitModel copyWith', () {
      final original = SplitModel(paymentPlans: []);
      final copied = original.copyWith(
        paymentPlans: [PaymentPlans(name: 'New Plan', payments: [])],
      );

      expect(copied.paymentPlans!.length, 1);
      expect(copied.paymentPlans![0]!.name, 'New Plan');
    });

    test('SplitModel equality', () {
      final model1 = SplitModel(
        paymentPlans: [
          PaymentPlans(
            name: 'Plan',
            payments: [Payments(to: 'A', amount: 10.0)],
          ),
        ],
      );
      final model2 = SplitModel(
        paymentPlans: [
          PaymentPlans(
            name: 'Plan',
            payments: [Payments(to: 'A', amount: 10.0)],
          ),
        ],
      );

      expect(model1, model2);
    });
  });
}
