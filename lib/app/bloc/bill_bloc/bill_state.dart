import 'package:equatable/equatable.dart';

import '../../models/bill.dart';

sealed class BillState extends Equatable {
  const BillState();

  @override
  List<Object?> get props => [];
}

final class BillInitial extends BillState {
  const BillInitial();
}

final class BillLoading extends BillState {
  const BillLoading();
}

final class BillLoaded extends BillState {
  const BillLoaded(this.bills);

  final List<Bill> bills;

  @override
  List<Object?> get props => [bills];
}

final class BillError extends BillState {
  const BillError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
