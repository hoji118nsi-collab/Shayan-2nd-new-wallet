import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'pages/home_page.dart';
import 'models/transaction.dart';
import 'models/investment.dart';
import 'models/future_purchase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // مقداردهی اولیه Hive
  await Hive.initFlutter();

  // ثبت آداپترها
  Hive.registerAdapter(TransactionAdapter());
  Hive.registerAdapter(InvestmentAdapter());
  Hive.registerAdapter(FuturePurchaseAdapter());

  // باز کردن Boxها
  await Hive.openBox<Transaction>('transactions');
  await Hive.openBox<Investment>('investments');
  await Hive.openBox<FuturePurchase>('futurePurchases');
  await Hive.openBox<String>('categories'); // اضافه شده برای دسته‌بندی خریدها

  runApp(ShayanWalletApp());
}

class ShayanWalletApp extends StatelessWidget {
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
