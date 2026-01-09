import 'package:freezed_annotation/freezed_annotation.dart';

part 'split_model.freezed.dart';

part 'split_model.g.dart';

@unfreezed
abstract class SplitModel with _$SplitModel {
  factory SplitModel({@JsonKey(name: 'payment_plans') List<PaymentPlans?>? paymentPlans}) = _SplitModel;

  factory SplitModel.fromJson(Map<String, dynamic> json) => _$SplitModelFromJson(json);
}

@unfreezed
abstract class PaymentPlans with _$PaymentPlans {
  factory PaymentPlans({String? name, List<Payments?>? payments}) = _PaymentPlans;

  factory PaymentPlans.fromJson(Map<String, dynamic> json) => _$PaymentPlansFromJson(json);
}

@unfreezed
abstract class Payments with _$Payments {
  factory Payments({String? to, int? amount}) = _Payments;

  factory Payments.fromJson(Map<String, dynamic> json) => _$PaymentsFromJson(json);
}
