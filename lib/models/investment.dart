import 'package:hive/hive.dart';

part 'investment.g.dart';

@HiveType(typeId: 1)
class Investment extends HiveObject {
  @HiveField(0)
  int amount;

  Investment({required this.amount});
}
