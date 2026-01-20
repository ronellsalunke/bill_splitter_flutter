import 'package:equatable/equatable.dart';

import '../../models/bill.dart';

abstract class BillState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BillInitial extends BillState {}

class BillLoading extends BillState {}

class BillLoaded extends BillState {
  BillLoaded(this.bills);

  final List<Bill> bills;

  @override
  List<Object?> get props => [bills];
}

class BillError extends BillState {
  BillError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
