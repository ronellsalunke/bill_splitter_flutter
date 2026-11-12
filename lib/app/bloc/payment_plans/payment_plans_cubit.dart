import 'dart:async';

import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_state.dart';
import 'package:bs_flutter/app/data/api_failure.dart';
import 'package:bs_flutter/app/data/result.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentPlansCubit extends Cubit<PaymentPlansState> {
  PaymentPlansCubit(this._repository) : super(const PaymentPlansInitial());

  final AppRepository _repository;

  List<Bill> _bills = const [];

  void calculateSplit(List<Bill> bills) {
    _bills = bills;
    unawaited(_calculateSplit(bills));
  }

  void retry() {
    if (state is! PaymentPlansOffline && state is! PaymentPlansError) return;
    if (_bills.isEmpty) return;
    unawaited(_calculateSplit(_bills));
  }

  Future<void> _calculateSplit(List<Bill> bills) async {
    emit(const PaymentPlansLoading());
    final result = await _repository.calculateSplit(bills);
    switch (result) {
      case Success(value: final splitModel):
        if (splitModel.paymentPlans == null || splitModel.paymentPlans!.isEmpty) {
          emit(const PaymentPlansError('No payment plans available'));
        } else {
          emit(PaymentPlansLoaded(splitModel));
        }
      case FailureResult(failure: final failure) when failure.kind == ApiFailureKind.network:
        emit(const PaymentPlansOffline());
      case FailureResult(failure: final failure):
        emit(PaymentPlansError(failure.userMessage));
    }
  }
}
