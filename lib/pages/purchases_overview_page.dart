import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import '../models/transaction.dart';

class PurchasesOverviewPage extends StatefulWidget {
  final Jalali? startDate;
  final Jalali? endDate;

  PurchasesOverviewPage({this.startDate, this.endDate});

  @override
  _PurchasesOverviewPageState createState() => _PurchasesOverviewPageState();
}

class _PurchasesOverviewPageState extends State<PurchasesOverviewPage> {
  late Box<Transaction> transactionBox;
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
    List<Transaction> allTx = transactionBox.values.toList();
    // فقط تراکنش‌های هزینه
    return allTx.where((tx) {
      if (tx.amount >= 0) return false;

      final txDate = Jalali.fromDateTime(tx.date);
      bool afterStart = startDate == null || !txDate.isBefore(startDate!);
      bool beforeEnd = endDate == null || !txDate.isAfter(endDate!);
      return afterStart && beforeEnd;
    }).toList();
  }

  Map<String, List<Transaction>> groupByCategory(List<Transaction> transactions) {
    Map<String, List<Transaction>> grouped = {};
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
    List<Transaction> txList = filteredTransactions();
    Map<String, List<Transaction>> grouped = groupByCategory(txList);

    return Scaffold(
      appBar: AppBar(
        title: Text('خریدهای انجام شده'),
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
                padding: EdgeInsets.all(8),
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
                    SizedBox(width: 8),
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
                      double total =
                          entry.value.fold(0, (prev, tx) => prev + tx.amount);
                      return Card(
                        color: Colors.white70,
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ExpansionTile(
                          title: Text(
                            '${entry.key} (تعداد: ${entry.value.length}, مجموع: $total تومان)',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          children: entry.value.map((tx) {
                            final txJalali = Jalali.fromDateTime(tx.date);
                            return ListTile(
                              title: Text(tx.title),
                              subtitle: Text(
                                  'تاریخ: ${txJalali.formatCompactDate()}'),
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
