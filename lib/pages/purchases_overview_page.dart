import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/transaction.dart';

class PurchasesOverviewPage extends StatefulWidget {
  final Jalali? startDate;
  final Jalali? endDate;

  const PurchasesOverviewPage({Key? key, this.startDate, this.endDate}) : super(key: key);

  @override
  _PurchasesOverviewPageState createState() => _PurchasesOverviewPageState();
}

class _PurchasesOverviewPageState extends State<PurchasesOverviewPage> {
  late final Box<Transaction> transactionBox;
  Jalali? startDate;
  Jalali? endDate;

  final List<String> categories = [
    'خوراکی',
    'تفریح',
    'کتاب',
    'مدرسه',
    'یهویی',
    'سایر',
  ];

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<Transaction>('transactions');
    startDate = widget.startDate;
    endDate = widget.endDate;
  }

  Future<void> pickStartDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: startDate ?? Jalali.now(),
      firstDate: Jalali(1370, 1),
      lastDate: Jalali.now(),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickEndDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: endDate ?? Jalali.now(),
      firstDate: Jalali(1370, 1),
      lastDate: Jalali.now(),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  List<Transaction> filteredTransactions() {
    final allTx = transactionBox.values.toList();
    return allTx.where((tx) {
      if (tx.amount >= 0) return false;

      final txDate = Jalali.fromDateTime(tx.date);
      final afterStart = startDate == null || !txDate.isBefore(startDate!);
      final beforeEnd = endDate == null || !txDate.isAfter(endDate!);
      return afterStart && beforeEnd;
    }).toList();
  }

  Map<String, List<Transaction>> groupByCategory(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    for (var cat in categories) grouped[cat] = [];

    for (var tx in transactions) {
      bool matched = false;
      for (var cat in categories.sublist(0, categories.length - 1)) {
        if (tx.title.contains(cat)) {
          grouped[cat]!.add(tx);
          matched = true;
          break;
        }
      }
      if (!matched) grouped['سایر']!.add(tx);
    }

    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final txList = filteredTransactions();
    final grouped = groupByCategory(txList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('خریدهای انجام شده'),
        centerTitle: true,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/minecraft.jpg',
            fit: BoxFit.cover,
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pickStartDate,
                        child: Text(startDate == null
                            ? 'انتخاب تاریخ شروع'
                            : 'شروع: ${startDate!.formatCompactDate()}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pickEndDate,
                        child: Text(endDate == null
                            ? 'انتخاب تاریخ پایان'
                            : 'پایان: ${endDate!.formatCompactDate()}'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: grouped.entries.map((entry) {
                      final total = entry.value.fold<int>(0, (prev, tx) => prev + tx.amount);
                      return Card(
                        color: Colors.white70,
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ExpansionTile(
                          title: Text(
                            '${entry.key} (تعداد: ${entry.value.length}, مجموع: $total تومان)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: entry.value.map((tx) {
                            final txJalali = Jalali.fromDateTime(tx.date);
                            return ListTile(
                              title: Text(tx.title),
                              subtitle: Text('تاریخ: ${txJalali.formatCompactDate()}'),
                              trailing: Text('${tx.amount} تومان'),
                            );
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
