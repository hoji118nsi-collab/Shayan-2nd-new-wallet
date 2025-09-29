import 'package:flutter/material.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'purchases_overview_page.dart';
import '../widgets/custom_button.dart';

class SelectDateRangePage extends StatefulWidget {
  @override
  _SelectDateRangePageState createState() => _SelectDateRangePageState();
}

class _SelectDateRangePageState extends State<SelectDateRangePage> {
  Jalali? startDate;
  Jalali? endDate;

  Future<void> _pickStartDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: startDate ?? Jalali.now(),
      firstDate: Jalali(1379, 1),
      lastDate: Jalali(1500, 12),
    );
    if (picked != null) {
      setState(() {
        startDate = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showPersianDatePicker(
      context: context,
      initialDate: endDate ?? Jalali.now(),
      firstDate: Jalali(1379, 1),
      lastDate: Jalali(1500, 12),
    );
    if (picked != null) {
      setState(() {
        endDate = picked;
      });
    }
  }

  void _viewPurchases() {
    if (startDate != null && endDate != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PurchasesOverviewPage(
            startDate: startDate!,
            endDate: endDate!,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لطفاً هر دو تاریخ را انتخاب کنید')),
      );
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
            'assets/images/minecraft.jpg',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 60),
                CustomButton(
                  text: startDate == null
                      ? 'تاریخ شروع'
                      : 'تاریخ شروع: ${startDate!.formatCompactDate()}',
                  color: Color(0xFFF28C28),
                  onPressed: _pickStartDate,
                ),
                SizedBox(height: 12),
                CustomButton(
                  text: endDate == null
                      ? 'تاریخ پایان'
                      : 'تاریخ پایان: ${endDate!.formatCompactDate()}',
                  color: Color(0xFF28B463),
                  onPressed: _pickEndDate,
                ),
                SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'مشاهده',
                        color: Color(0xFF2874A6),
                        onPressed: _viewPurchases,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'انصراف',
                        color: Colors.grey.shade700,
                        onPressed: _cancel,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
