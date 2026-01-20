import 'package:freezed_annotation/freezed_annotation.dart';

part 'split_model.freezed.dart';
part 'split_model.g.dart';

@freezed
abstract class SplitModel with _$SplitModel {
  @JsonSerializable(explicitToJson: true)
  factory SplitModel({@JsonKey(name: 'payment_plans') List<PaymentPlans?>? paymentPlans}) = _SplitModel;

  factory SplitModel.fromJson(Map<String, dynamic> json) => _$SplitModelFromJson(json);
}

@freezed
abstract class PaymentPlans with _$PaymentPlans {
  @JsonSerializable(explicitToJson: true)
  factory PaymentPlans({String? name, List<Payments?>? payments}) = _PaymentPlans;

  factory PaymentPlans.fromJson(Map<String, dynamic> json) => _$PaymentPlansFromJson(json);
}

@freezed
abstract class Payments with _$Payments {
  @JsonSerializable(explicitToJson: true)
  factory Payments({String? to, double? amount}) = _Payments;

  factory Payments.fromJson(Map<String, dynamic> json) => _$PaymentsFromJson(json);
}
