import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
class Transaction extends HiveObject {
  @HiveField(0)
  final String title; // عنوان تراکنش: پول تو جیبی، کادو، جایزه، هزینه
  @HiveField(1)
  final int amount;
  @HiveField(2)
  final DateTime date; // برای سازگاری با Hive، همچنان DateTime نگه داشته می‌شود

  Transaction({
    required this.title,
    required this.amount,
    required this.date,
  });

  // Getter برای تبدیل به DateTime هنگام نمایش
  DateTime get toDateTime => date;
}
