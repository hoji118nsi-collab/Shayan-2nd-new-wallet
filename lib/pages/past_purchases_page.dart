import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class PastPurchasesPage extends StatefulWidget {
  @override
  _PastPurchasesPageState createState() => _PastPurchasesPageState();
}

class _PastPurchasesPageState extends State<PastPurchasesPage> {
  late Box<Transaction> transactionBox;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    transactionBox = Hive.box<Transaction>('transactions');
  }

  Future<void> pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 30)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => startDate = picked);
  }

  Future<void> pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => endDate = picked);
  }

  List<Transaction> filteredTransactions() {
    List<Transaction> allTx = transactionBox.values.toList();
    // فقط تراکنش‌های هزینه (مقادیر منفی)
    return allTx.where((tx) {
      if (tx.amount >= 0) return false;
      bool afterStart = startDate == null || !tx.date.isBefore(startDate!);
      bool beforeEnd = endDate == null || !tx.date.isAfter(endDate!);
      return afterStart && beforeEnd;
    }).toList();
  }

  Map<String, List<Transaction>> groupByCategory(List<Transaction> transactions) {
    Map<String, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      String cat = tx.title;
      grouped.putIfAbsent(cat, () => []);
      grouped[cat]!.add(tx);
    }
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
                            : 'شروع: ${startDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: pickEndDate,
                        child: Text(endDate == null
                            ? 'انتخاب تاریخ پایان'
                            : 'پایان: ${endDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: grouped.entries.map((entry) {
                    double total = entry.value.fold(0, (prev, tx) => prev + tx.amount);
                    return Card(
                      color: Colors.white70,
                      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ExpansionTile(
                        title: Text(
                            '${entry.key} (تعداد: ${entry.value.length}, مجموع: $total تومان)'),
                        children: entry.value.map((tx) {
                          return ListTile(
                            title: Text(tx.title),
                            subtitle: Text(
                                'تاریخ: ${tx.date.toLocal().toString().split(' ')[0]}'),
                            trailing: Text('${tx.amount} تومان'),
                          );
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
