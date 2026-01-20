import 'package:hive_ce/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bill.g.dart';

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 0)
class Bill extends HiveObject {
  @HiveField(0)
  String id;
  @HiveField(1)
  String paidBy;
  @HiveField(2)
  double amount;
  @HiveField(3)
  double tax;
  @HiveField(4)
  double service;
  @HiveField(5)
  List<BillItem> items;
  @HiveField(6)
  DateTime createdAt;

  Bill({
    required this.id,
    required this.paidBy,
    required this.amount,
    required this.tax,
    required this.service,
    required this.items,
    required this.createdAt,
  });

  factory Bill.fromJson(Map<String, dynamic> json) => _$BillFromJson(json);

  Map<String, dynamic> toJson() => _$BillToJson(this);
}

@JsonSerializable(explicitToJson: true)
@HiveType(typeId: 1)
class BillItem extends HiveObject {
  @HiveField(0)
  String name;
  @HiveField(1)
  double price;
  @HiveField(2)
  int quantity;
  @HiveField(3)
  List<String> consumedBy;

  BillItem({required this.name, required this.price, required this.quantity, required this.consumedBy});

  factory BillItem.fromJson(Map<String, dynamic> json) => _$BillItemFromJson(json);

  Map<String, dynamic> toJson() => _$BillItemToJson(this);
}
