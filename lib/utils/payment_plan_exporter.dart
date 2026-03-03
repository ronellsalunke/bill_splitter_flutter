import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:bs_flutter/extensions/extensions.dart';

class PaymentPlanExporter {
  static String exportToText(SplitModel splitModel) {
    if (splitModel.paymentPlans == null || splitModel.paymentPlans!.isEmpty) {
      return 'No payment plans available.';
    }

    // Map format: Map<Payee, List<MapEntry<Payer, Amount>>>
    final Map<String, List<MapEntry<String, double>>> payeesMap = {};

    for (final plan in splitModel.paymentPlans!) {
      if (plan == null || plan.name == null) continue;

      final payer = plan.name!.trim();

      if (plan.payments != null) {
        for (final payment in plan.payments!) {
          if (payment == null || payment.to == null || payment.amount == null) {
            continue;
          }

          final payee = payment.to!.trim();
          final amount = payment.amount!;

          if (payee.isNotEmpty && amount > 0) {
            payeesMap.putIfAbsent(payee, () => []).add(MapEntry(payer, amount));
          }
        }
      }
    }

    if (payeesMap.isEmpty) {
      return 'No pending payments.';
    }

    final buffer = StringBuffer();

    payeesMap.forEach((payee, pairs) {
      buffer.writeln('To pay ${payee.toCapitalized}:');

      for (final pair in pairs) {
        final payer = pair.key.toCapitalized;
        final amountString = pair.value == pair.value.truncateToDouble()
            ? pair.value.toInt().toString()
            : pair.value.toStringAsFixed(2);

        buffer.writeln('$payer → ₹$amountString');
      }
      buffer.writeln();
    });

    return buffer.toString().trimRight();
  }
}
