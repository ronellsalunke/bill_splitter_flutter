import '../../models/bill.dart';

abstract class BillState {}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  BillLoaded(this.bills);

  final List<Bill> bills;
}

class BillError extends BillState {
  BillError(this.message);

  final String message;
}
