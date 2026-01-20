import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_model.freezed.dart';
part 'ocr_model.g.dart';

@freezed
abstract class OcrModel with _$OcrModel {
  @JsonSerializable(explicitToJson: true)
  factory OcrModel({
    List<Items?>? items,
    @JsonKey(name: 'tax_rate') double? taxRate,
    @JsonKey(name: 'service_charge') double? serviceCharge,
    @JsonKey(name: 'amount_paid') double? amountPaid,
  }) = _OcrModel;

  factory OcrModel.fromJson(Map<String, dynamic> json) => _$OcrModelFromJson(json);
}

@freezed
abstract class Items with _$Items {
  @JsonSerializable(explicitToJson: true)
  factory Items({String? name, double? price, int? quantity}) = _Items;

  factory Items.fromJson(Map<String, dynamic> json) => _$ItemsFromJson(json);
}
