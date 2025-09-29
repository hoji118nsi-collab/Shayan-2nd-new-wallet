import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/investment.dart';

class TransferToInvestmentPage extends StatefulWidget {
  final int walletAmount;
  TransferToInvestmentPage({required this.walletAmount});

  @override
  _TransferToInvestmentPageState createState() => _TransferToInvestmentPageState();
}

class _TransferToInvestmentPageState extends State<TransferToInvestmentPage> {
  final TextEditingController _controller = TextEditingController();

  void transfer() {
    int amount = int.tryParse(_controller.text) ?? 0;
    if (amount <= 0 || amount > widget.walletAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مقدار نامعتبر است!')),
      );
      return;
    }

    final investBox = Hive.box<Investment>('investments');
    if (investBox.isEmpty) investBox.add(Investment(amount: 0));
    int currentInvestment = investBox.getAt(0)!.amount;
    investBox.putAt(0, Investment(amount: currentInvestment + amount));

    final transactionsBox = Hive.box<Transaction>('transactions');
    transactionsBox.add(Transaction(
      title: 'انتقال به سرمایه‌گذاری',
      amount: -amount,
      date: DateTime.now(),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('مقدار $amount به صندوق سرمایه‌گذاری منتقل شد!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('انتقال به صندوق سرمایه‌گذاری')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('موجودی کیف پول: ${widget.walletAmount}'),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'مقدار انتقال'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: transfer,
              child: Text('انتقال'),
            ),
          ],
        ),
      ),
    );
  }
}
