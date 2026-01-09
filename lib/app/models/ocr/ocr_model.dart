import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_model.freezed.dart';

part 'ocr_model.g.dart';

@unfreezed
abstract class OcrModel with _$OcrModel {
  factory OcrModel({
    List<Items?>? items,
    @JsonKey(name: 'tax_rate') int? taxRate,
    @JsonKey(name: 'service_charge') int? serviceCharge,
    @JsonKey(name: 'amount_paid') int? amountPaid,
  }) = _OcrModel;

  factory OcrModel.fromJson(Map<String, dynamic> json) => _$OcrModelFromJson(json);
}

@unfreezed
abstract class Items with _$Items {
  factory Items({String? name, int? price, int? quantity}) = _Items;

  factory Items.fromJson(Map<String, dynamic> json) => _$ItemsFromJson(json);
}
