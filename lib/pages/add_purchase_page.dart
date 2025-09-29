import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../widgets/custom_button.dart';

class AddPurchasePage extends StatefulWidget {
  @override
  _AddPurchasePageState createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String? _selectedCategory;

  late Box<String> categoryBox;
  List<String> categories = [];

  @override
  void initState() {
    super.initState();
    categoryBox = Hive.box<String>('categories');

    // اگر Hive خالی بود، مقادیر پیش‌فرض را اضافه کن
    if (categoryBox.isEmpty) {
      final defaultCategories = [
        'خوراکی (رستوران، سوپرمارکت)',
        'تفریح و سرگرمی',
        'کتاب و مطالعه',
        'لوازم التحریر و مدرسه',
        'خرید یهویی و بدون برنامه',
      ];
      for (var cat in defaultCategories) categoryBox.add(cat);
    }

    categories = categoryBox.values.toList();
    categories.add('افزودن دسته‌بندی جدید');
  }

  void _savePurchase() {
    if (_selectedCategory != null &&
        _titleController.text.isNotEmpty &&
        _amountController.text.isNotEmpty) {
      final amount = int.tryParse(_amountController.text);
      if (amount != null) {
        final box = Hive.box<Transaction>('transactions');
        box.add(Transaction(
          title: _titleController.text,
          amount: -amount,
          date: DateTime.now(),
        ));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('لطفاً مبلغ معتبر وارد کنید')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تمام فیلدها را پر کنید')),
      );
    }
  }

  void _addNewCategory() async {
    final TextEditingController newCatController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('افزودن دسته‌بندی جدید'),
        content: TextField(
          controller: newCatController,
          decoration: InputDecoration(hintText: 'نام دسته‌بندی'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('لغو'),
          ),
          TextButton(
            onPressed: () {
              final newCat = newCatController.text.trim();
              if (newCat.isNotEmpty && !categoryBox.values.contains(newCat)) {
                categoryBox.add(newCat);
              }
              Navigator.pop(context);
            },
            child: Text('افزودن'),
          ),
        ],
      ),
    );

    setState(() {
      categories = categoryBox.values.toList();
      categories.add('افزودن دسته‌بندی جدید');
      _selectedCategory = null;
    });
  }

  void _onCategoryChanged(String? val) {
    if (val == 'افزودن دسته‌بندی جدید') {
      _addNewCategory();
    } else {
      setState(() {
        _selectedCategory = val;
      });
    }
  }

  void _cancel() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/need4speed.jpg',
            fit: BoxFit.cover,
          ),
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  hint: Text('انتخاب دسته‌بندی خرید'),
                  items: categories.map((cat) {
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: _onCategoryChanged,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'عنوان خرید',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'مبلغ خرید',
                    filled: true,
                    fillColor: Colors.white70,
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 24),
                CustomButton(
                  text: 'تایید',
                  color: Color(0xFFF28C28),
                  onPressed: _savePurchase,
                ),
                SizedBox(height: 12),
                CustomButton(
                  text: 'انصراف',
                  color: Colors.grey.shade700,
                  onPressed: _cancel,
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
