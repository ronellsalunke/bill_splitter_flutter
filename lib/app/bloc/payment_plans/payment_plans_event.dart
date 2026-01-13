import 'package:bs_flutter/app/models/bill.dart';

abstract class PaymentPlansEvent {}

class CalculateSplit extends PaymentPlansEvent {
  CalculateSplit(this.bills);

  final List<Bill> bills;
}
