import 'dart:async';

import 'package:bs_flutter/app/bloc/payment_plans/payment_plans_state.dart';
import 'package:bs_flutter/app/data/result.dart';
import 'package:bs_flutter/app/models/bill.dart';
import 'package:bs_flutter/app/repository/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PaymentPlansCubit extends Cubit<PaymentPlansState> {
  PaymentPlansCubit(this._repository) : super(PaymentPlansInitial());

  final AppRepository _repository;

  void calculateSplit(List<Bill> bills) {
    unawaited(_calculateSplit(bills));
  }

  Future<void> _calculateSplit(List<Bill> bills) async {
    emit(PaymentPlansLoading());
    final result = await _repository.calculateSplit(bills);
    switch (result) {
      case Success(value: final splitModel):
        if (splitModel.paymentPlans == null || splitModel.paymentPlans!.isEmpty) {
          emit(PaymentPlansError('No payment plans available'));
        } else {
          emit(PaymentPlansLoaded(splitModel));
        }
      case FailureResult(failure: final failure):
        emit(PaymentPlansError(failure.userMessage));
    }
  }
}
