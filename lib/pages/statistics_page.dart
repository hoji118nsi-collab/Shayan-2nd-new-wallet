import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../widgets/custom_button.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  int monthlyIncome = 0;
  int monthlyExpense = 0;
  int yearlyIncome = 0;
  int yearlyExpense = 0;

  Map<String, int> categoryTotals = {};

  final List<String> categories = [
    'خوراکی',
    'تفریح',
    'کتاب',
    'مدرسه',
    'یهویی',
    'سایر'
  ];

  final Map<String, Color> categoryColors = {
    'خوراکی': Colors.red,
    'تفریح': Colors.green,
    'کتاب': Colors.blue,
    'مدرسه': Colors.purple,
    'یهویی': Colors.orange,
    'سایر': Colors.grey,
  };

  void calculateStats() {
    final transactions = Hive.box<Transaction>('transactions').values.toList();
    final now = DateTime.now();

    int monthInc = 0;
    int monthExp = 0;
    int yearInc = 0;
    int yearExp = 0;

    categoryTotals.clear();
    for (var cat in categories) {
      categoryTotals[cat] = 0;
    }

    for (var t in transactions) {
      // محاسبه درآمد و هزینه
      if (t.date.year == now.year) {
        if (t.date.month == now.month) {
          if (t.amount > 0)
            monthInc += t.amount;
          else
            monthExp += -t.amount;
        }
        if (t.amount > 0)
          yearInc += t.amount;
        else
          yearExp += -t.amount;
      }

      // محاسبه مجموع خریدها بر اساس دسته‌بندی برای نمودار
      if (t.amount < 0) {
        bool matched = false;
        for (var cat in categories.sublist(0, categories.length - 1)) {
          if (t.title.contains(cat)) {
            categoryTotals[cat] = categoryTotals[cat]! + (-t.amount);
            matched = true;
            break;
          }
        }
        if (!matched) categoryTotals['سایر'] = categoryTotals['سایر']! + (-t.amount);
      }
    }

    setState(() {
      monthlyIncome = monthInc;
      monthlyExpense = monthExp;
      yearlyIncome = yearInc;
      yearlyExpense = yearExp;
    });
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final List<PieChartSectionData> sections = [];
    categoryTotals.forEach((category, amount) {
      if (amount > 0) {
        sections.add(PieChartSectionData(
          color: categoryColors[category],
          value: amount.toDouble(),
          title: '$category\n$amount',
          titleStyle: TextStyle(color: Colors.white, fontSize: 12),
        ));
      }
    });
    return sections;
  }

  @override
  void initState() {
    super.initState();
    calculateStats();
    Hive.box<Transaction>('transactions').watch().listen((event) {
      calculateStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('آمار ماهانه و سالانه')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/minecraft.jpg',
            fit: BoxFit.cover,
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16),
                Text(
                  'آمار ماه جاری',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Text('درآمد: $monthlyIncome تومان',
                    style: TextStyle(color: Colors.white70)),
                Text('هزینه: $monthlyExpense تومان',
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 24),
                Text(
                  'آمار سال جاری',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 8),
                Text('درآمد: $yearlyIncome تومان',
                    style: TextStyle(color: Colors.white70)),
                Text('هزینه: $yearlyExpense تومان',
                    style: TextStyle(color: Colors.white70)),
                SizedBox(height: 32),
                Text(
                  'نمودار خریدها',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: _buildPieChartSections(),
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      borderData: FlBorderData(show: false),
                    ),
                    swapAnimationDuration: Duration(milliseconds: 500),
                  ),
                ),
                SizedBox(height: 32),
                CustomButton(
                  text: 'بازگشت',
                  color: Color(0xFFF28C28),
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
