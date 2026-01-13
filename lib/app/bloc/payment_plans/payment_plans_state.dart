import 'package:bs_flutter/app/models/split/split_model.dart';

abstract class PaymentPlansState {}

class PaymentPlansInitial extends PaymentPlansState {}

class PaymentPlansLoading extends PaymentPlansState {}

class PaymentPlansLoaded extends PaymentPlansState {
  PaymentPlansLoaded(this.splitModel);

  final SplitModel splitModel;
}

class PaymentPlansError extends PaymentPlansState {
  PaymentPlansError(this.message);

  final String message;
}
