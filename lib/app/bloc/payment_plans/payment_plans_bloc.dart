import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/repository.dart';
import 'payment_plans_event.dart';
import 'payment_plans_state.dart';

class PaymentPlansBloc extends Bloc<PaymentPlansEvent, PaymentPlansState> {
  final AppRepository _repository;

  PaymentPlansBloc(this._repository) : super(PaymentPlansInitial()) {
    on<CalculateSplit>(_onCalculateSplit);
  }

  Future<void> _onCalculateSplit(CalculateSplit event, Emitter<PaymentPlansState> emit) async {
    emit(PaymentPlansLoading());
    try {
      final splitModel = await _repository.calculateSplit(event.bills);
      if (splitModel.paymentPlans == null || splitModel.paymentPlans!.isEmpty) {
        emit(PaymentPlansError('No payment plans available'));
      } else {
        emit(PaymentPlansLoaded(splitModel));
      }
    } catch (e) {
      emit(PaymentPlansError('API error: Unable to calculate split'));
    }
  }
}
