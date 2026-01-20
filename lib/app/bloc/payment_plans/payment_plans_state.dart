import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:equatable/equatable.dart';

abstract class PaymentPlansState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaymentPlansInitial extends PaymentPlansState {}

class PaymentPlansLoading extends PaymentPlansState {}

class PaymentPlansLoaded extends PaymentPlansState {
  PaymentPlansLoaded(this.splitModel);

  final SplitModel splitModel;

  @override
  List<Object?> get props => [splitModel];
}

class PaymentPlansError extends PaymentPlansState {
  PaymentPlansError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
