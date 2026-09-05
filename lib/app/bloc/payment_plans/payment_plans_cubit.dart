import 'dart:async';

import 'package:bs_flutter/app/models/bill.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/repository.dart';
import 'payment_plans_state.dart';

class PaymentPlansCubit extends Cubit<PaymentPlansState> {
  PaymentPlansCubit(this._repository) : super(PaymentPlansInitial());

  final AppRepository _repository;

  void calculateSplit(List<Bill> bills) {
    unawaited(_calculateSplit(bills));
  }

  Future<void> _calculateSplit(List<Bill> bills) async {
    emit(PaymentPlansLoading());
    try {
      final splitModel = await _repository.calculateSplit(bills);
      if (splitModel.paymentPlans == null || splitModel.paymentPlans!.isEmpty) {
        emit(PaymentPlansError('No payment plans available'));
      } else {
        emit(PaymentPlansLoaded(splitModel));
      }
    } catch (_) {
      emit(PaymentPlansError('API error: Unable to calculate split'));
    }
  }
}
