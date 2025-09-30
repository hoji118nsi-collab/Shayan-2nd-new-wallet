import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/investment.dart';
import '../widgets/card_widget.dart';
import '../widgets/custom_button.dart';
import 'add_purchase_page.dart';
import 'future_purchases_page.dart';
import 'statistics_page.dart';
import 'select_date_range_page.dart';
import 'add_transaction_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int walletAmount = 0;
  late final Box<Transaction> transactionsBox;
  late final Box<Investment> investmentsBox;

  @override
  void initState() {
    super.initState();
    if (Hive.isBoxOpen('transactions')) {
      transactionsBox = Hive.box<Transaction>('transactions');
      transactionsBox.watch().listen((event) => _calculateWallet());
    }
    if (Hive.isBoxOpen('investments')) {
      investmentsBox = Hive.box<Investment>('investments');
    }
    _calculateWallet();
  }

  void _calculateWallet() {
    if (Hive.isBoxOpen('transactions')) {
      final txs = Hive.box<Transaction>('transactions').values.toList();
      final sum = txs.fold<int>(0, (prev, t) => prev + t.amount);
      setState(() => walletAmount = sum);
    }
  }

  void _calculateInvestment() {
    if (!Hive.isBoxOpen('investments')) return;
    final investBox = Hive.box<Investment>('investments');
    if (investBox.isEmpty) {
      investBox.add(Investment(amount: 0));
    }
    int currentInvestment = investBox.getAt(0)?.amount ?? 0;
    int remaining = walletAmount > 0 ? walletAmount : 0;

    if (remaining > 0) {
      int bonus = remaining;
      investBox.putAt(0, Investment(amount: currentInvestment + remaining + bonus));

      if (Hive.isBoxOpen('transactions')) {
        Hive.box<Transaction>('transactions').add(
          Transaction(
            title: 'انتقال به صندوق سرمایه گذاری',
            amount: -remaining,
            date: DateTime.now(),
          ),
        );
      }
      _calculateWallet();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Hive.isBoxOpen('investments')) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final investBox = Hive.box<Investment>('investments');
    final investAmount = investBox.getAt(0)?.amount ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('کیف پول شایان'),
        centerTitle: true,
      ),
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
                CardWidget(title: "کیف پول", amount: walletAmount),
                CardWidget(title: "موجودی صندوق سرمایه گذاری", amount: investAmount),
                const SizedBox(height: 20),

                CustomButton(
                  text: "ثبت ورود پول",
                  color: const Color(0xFF27AE60),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddTransactionPage(isIncome: true)),
                    );
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: "ثبت خرید جدید",
                  color: const Color(0xFFF28C28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => AddPurchasePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: "مشاهده خریدهای انجام شده",
                  color: const Color(0xFF28B463),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SelectDateRangePage()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: "انتقال به صندوق سرمایه گذاری",
                  color: const Color(0xFF2874A6),
                  onPressed: () {
                    _calculateInvestment();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('پس‌انداز به صندوق سرمایه گذاری منتقل شد!')),
                    );
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: "لیست خریدهای آتی",
                  color: const Color(0xFF8E44AD),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FuturePurchasesPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: "مشاهده آمار ماهانه و سالانه",
                  color: const Color(0xFFF28C28),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatisticsPage()),
                    );
                  },
                ),
                const SizedBox(height: 12),

                CustomButton(
                  text: "تست Hive",
                  color: Colors.blue,
                  onPressed: () {
                    try {
                      if (!Hive.isBoxOpen('transactions') || !Hive.isBoxOpen('investments')) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Box ها هنوز باز نشده‌اند ❌')),
                        );
                        return;
                      }

                      var txBox = Hive.box<Transaction>('transactions');
                      var investBox = Hive.box<Investment>('investments');

                      txBox.add(Transaction(title: 'تست تراکنش', amount: 1000, date: DateTime.now()));
                      if (investBox.isEmpty) {
                        investBox.add(Investment(amount: 5000));
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Box ها درست باز شدند و داده تستی اضافه شد ✅')),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطا در Hive ❌: $e')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
