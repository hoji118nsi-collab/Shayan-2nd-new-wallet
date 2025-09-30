import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/home_page.dart';
import 'models/transaction.dart';
import 'models/investment.dart';
import 'models/future_purchase.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // مقداردهی اولیه Hive
  await Hive.initFlutter();

  // ثبت آداپترها
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(InvestmentAdapter());
  Hive.registerAdapter(FuturePurchaseAdapter());

  // باز کردن Boxها با null-safety و آماده استفاده
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Investment>('investments');
  await Hive.openBox<FuturePurchase>('futurePurchases');
  await Hive.openBox<String>('categories');

  runApp(const ShayanWalletApp());
}

class ShayanWalletApp extends StatelessWidget {
  const ShayanWalletApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'کیف پول شایان',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        fontFamily: 'Shabnam',
      ),
      home: HomePage(),
    );
  }
}
