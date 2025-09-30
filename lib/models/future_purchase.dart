import 'package:hive/hive.dart';

part 'future_purchase.g.dart';

@HiveType(typeId: 2)
class FuturePurchase extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final int price;

  @HiveField(2)
  bool bought;

  FuturePurchase({
    required this.name,
    required this.price,
    this.bought = false,
  });
}
