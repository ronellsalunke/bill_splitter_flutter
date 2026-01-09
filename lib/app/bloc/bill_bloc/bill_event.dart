import '../../models/bill.dart';

abstract class BillEvent {}

class LoadBills extends BillEvent {}

class AddBill extends BillEvent {
  AddBill(this.bill);

  final Bill bill;
}

class UpdateBill extends BillEvent {
  UpdateBill(this.bill);

  final Bill bill;
}

class DeleteBill extends BillEvent {
  DeleteBill(this.id);

  final String id;
}
