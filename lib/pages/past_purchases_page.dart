import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';

class PastPurchasesPage extends StatefulWidget {
  const PastPurchasesPage({Key? key}) : super(key: key);

  @override
  _PastPurchasesPageState createState() => _PastPurchasesPageState();
}

class _PastPurchasesPageState extends State<PastPurchasesPage> {
  late final Box<Transaction> transactionBox;
  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    if (Hive.isBoxOpen('transactions')) {
      transactionBox = Hive.box<Transaction>('transactions');
    }
  }

  Future<void> pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 30)),
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
    final allTx = transactionBox.values.toList();
    return allTx.where((tx) {
      if (tx.amount >= 0) return false; // فقط هزینه
      final afterStart = startDate == null || !tx.date.isBefore(startDate!);
      final beforeEnd = endDate == null || !tx.date.isAfter(endDate!);
      return afterStart && beforeEnd;
    }).toList();
  }

  Map<String, List<Transaction>> groupByCategory(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    for (var tx in transactions) {
      grouped.putIfAbsent(tx.title, () => []).add(tx);
    }
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
                            : 'شروع: ${startDate!.toLocal().toString().split(' ')[0]}'),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                    final total = entry.value.fold<int>(0, (prev, tx) => prev + tx.amount);
                    return Card(
                      color: Colors.white70,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ExpansionTile(
                        title: Text(
                          '${entry.key} (تعداد: ${entry.value.length}, مجموع: $total تومان)',
                        ),
                        children: entry.value.map((tx) {
                          return ListTile(
                            title: Text(tx.title),
                            subtitle: Text(
                              'تاریخ: ${tx.date.toLocal().toString().split(' ')[0]}',
                            ),
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
