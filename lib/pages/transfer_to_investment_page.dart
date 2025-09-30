import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/investment.dart';

class TransferToInvestmentPage extends StatefulWidget {
  final int walletAmount;
  const TransferToInvestmentPage({Key? key, required this.walletAmount}) : super(key: key);

  @override
  _TransferToInvestmentPageState createState() => _TransferToInvestmentPageState();
}

class _TransferToInvestmentPageState extends State<TransferToInvestmentPage> {
  final TextEditingController _controller = TextEditingController();

  void transfer() {
    final int amount = int.tryParse(_controller.text) ?? 0;
    if (amount <= 0 || amount > widget.walletAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('مقدار نامعتبر است!')),
      );
      return;
    }

    final investBox = Hive.box<Investment>('investments');
    if (investBox.isEmpty) investBox.add(Investment(amount: 0));

    final currentInvestment = investBox.getAt(0)?.amount ?? 0;
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
      appBar: AppBar(title: const Text('انتقال به صندوق سرمایه‌گذاری')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('موجودی کیف پول: ${widget.walletAmount}'),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'مقدار انتقال',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: transfer,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2874A6)),
              child: const Text('انتقال'),
            ),
          ],
        ),
      ),
    );
  }
}
