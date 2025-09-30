import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/transaction.dart';
import '../widgets/custom_button.dart';

class AddTransactionPage extends StatefulWidget {
  final bool isIncome; // true = درآمد، false = هزینه
  const AddTransactionPage({Key? key, required this.isIncome}) : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  void _saveTransaction() {
    final title = _titleController.text.trim();
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لطفاً عنوان و مبلغ معتبر وارد کنید')),
      );
      return;
    }

    final transaction = Transaction(
      title: title,
      amount: widget.isIncome ? amount : -amount,
      date: DateTime.now(),
    );

    Hive.box<Transaction>('transactions').add(transaction);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isIncome ? "ثبت درآمد" : "ثبت هزینه"),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/need4speed.jpg',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 50),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "عنوان",
                    border: const OutlineInputBorder(),
                    fillColor: Colors.white70,
                    filled: true,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: "مبلغ",
                    border: const OutlineInputBorder(),
                    fillColor: Colors.white70,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  text: "ثبت",
                  color: const Color(0xFFF28C28),
                  onPressed: _saveTransaction,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: "انصراف",
                  color: Colors.grey.shade700,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
