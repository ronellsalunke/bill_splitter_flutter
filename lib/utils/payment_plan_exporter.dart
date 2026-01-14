import 'package:bs_flutter/app/models/split/split_model.dart';

class PaymentPlanExporter {
  /// Exports payment plans to plain text format
  static String exportToText(SplitModel splitModel) {
    final buffer = StringBuffer();
    buffer.writeln('Payment Plans\n');

    if (splitModel.paymentPlans == null || splitModel.paymentPlans!.isEmpty) {
      buffer.writeln('No payment plans available.');
      return buffer.toString();
    }

    for (final plan in splitModel.paymentPlans!) {
      if (plan == null) continue;

      final totalOwed = plan.payments?.fold(0.0, (sum, p) => sum + (p?.amount ?? 0)) ?? 0;
      buffer.writeln(plan.name ?? 'Unnamed Plan');
      buffer.writeln('Total owed: ₹${totalOwed.toStringAsFixed(2)}\n');

      if (plan.payments != null && plan.payments!.isNotEmpty) {
        buffer.writeln('Payments:');
        for (final payment in plan.payments!) {
          if (payment == null) continue;
          buffer.writeln('  → ${payment.to ?? 'Unknown'} : ₹${payment.amount?.toStringAsFixed(2) ?? '0.00'}');
        }
      }
      buffer.writeln('---\n');
    }

    return buffer.toString();
  }
}
