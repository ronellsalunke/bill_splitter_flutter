import 'package:freezed_annotation/freezed_annotation.dart';

part 'split_request_model.freezed.dart';
part 'split_request_model.g.dart';

@freezed
abstract class SplitRequest with _$SplitRequest {
  @JsonSerializable(explicitToJson: true)
  factory SplitRequest({required List<SplitBill> bills}) = _SplitRequest;

  factory SplitRequest.fromJson(Map<String, dynamic> json) => _$SplitRequestFromJson(json);
}

@freezed
abstract class SplitBill with _$SplitBill {
  @JsonSerializable(explicitToJson: true)
  factory SplitBill({
    required List<SplitItem> items,
    @JsonKey(name: 'paid_by') required String paidBy,
    @JsonKey(name: 'amount_paid') required double amountPaid,
    @JsonKey(name: 'tax_rate') required double taxRate,
    @JsonKey(name: 'service_charge') required double serviceCharge,
  }) = _SplitBill;

  factory SplitBill.fromJson(Map<String, dynamic> json) => _$SplitBillFromJson(json);
}

@freezed
abstract class SplitItem with _$SplitItem {
  @JsonSerializable(explicitToJson: true)
  factory SplitItem({
    required String name,
    required double price,
    required int quantity,
    @JsonKey(name: 'consumed_by') required List<String> consumedBy,
  }) = _SplitItem;

  factory SplitItem.fromJson(Map<String, dynamic> json) => _$SplitItemFromJson(json);
}
