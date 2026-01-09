import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce/hive.dart';

import '../../models/bill.dart';
import 'bill_event.dart';
import 'bill_state.dart';

class BillBloc extends Bloc<BillEvent, BillState> {
  final Box<Bill> _billBox;

  BillBloc(this._billBox) : super(BillInitial()) {
    on<LoadBills>(_onLoadBills);
    on<AddBill>(_onAddBill);
    on<UpdateBill>(_onUpdateBill);
    on<DeleteBill>(_onDeleteBill);
  }

  Future<void> _onLoadBills(LoadBills event, Emitter<BillState> emit) async {
    emit(BillLoading());
    try {
      final bills = _billBox.values.toList();
      emit(BillLoaded(bills));
    } catch (e) {
      emit(BillError('Failed to load bills: $e'));
    }
  }

  Future<void> _onAddBill(AddBill event, Emitter<BillState> emit) async {
    try {
      final bill = event.bill;
      await _billBox.put(bill.id, bill);
      add(LoadBills()); // Reload bills
    } catch (e) {
      emit(BillError('Failed to add bill: $e'));
    }
  }

  Future<void> _onUpdateBill(UpdateBill event, Emitter<BillState> emit) async {
    try {
      final bill = event.bill;
      await _billBox.put(bill.id, bill);
      add(LoadBills());
    } catch (e) {
      emit(BillError('Failed to update bill: $e'));
    }
  }

  Future<void> _onDeleteBill(DeleteBill event, Emitter<BillState> emit) async {
    try {
      await _billBox.delete(event.id);
      add(LoadBills());
    } catch (e) {
      emit(BillError('Failed to delete bill: $e'));
    }
  }
}
