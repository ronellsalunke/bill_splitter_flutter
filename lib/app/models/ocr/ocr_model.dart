import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_model.freezed.dart';

part 'ocr_model.g.dart';

@unfreezed
abstract class OcrModel with _$OcrModel {
  factory OcrModel({
    List<Items?>? items,
    @JsonKey(name: 'tax_rate') double? taxRate,
    @JsonKey(name: 'service_charge') double? serviceCharge,
    @JsonKey(name: 'amount_paid') double? amountPaid,
  }) = _OcrModel;

  factory OcrModel.fromJson(Map<String, dynamic> json) => _$OcrModelFromJson(json);
}

@unfreezed
abstract class Items with _$Items {
  factory Items({String? name, double? price, int? quantity}) = _Items;

  factory Items.fromJson(Map<String, dynamic> json) => _$ItemsFromJson(json);
}
