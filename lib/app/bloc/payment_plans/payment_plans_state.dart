import 'package:bs_flutter/app/models/split/split_model.dart';
import 'package:equatable/equatable.dart';

sealed class PaymentPlansState extends Equatable {
  const PaymentPlansState();

  @override
  List<Object?> get props => [];
}

final class PaymentPlansInitial extends PaymentPlansState {
  const PaymentPlansInitial();
}

final class PaymentPlansLoading extends PaymentPlansState {
  const PaymentPlansLoading();
}

final class PaymentPlansLoaded extends PaymentPlansState {
  const PaymentPlansLoaded(this.splitModel);

  final SplitModel splitModel;

  @override
  List<Object?> get props => [splitModel];
}

final class PaymentPlansError extends PaymentPlansState {
  const PaymentPlansError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class PaymentPlansOffline extends PaymentPlansState {
  const PaymentPlansOffline();
}
