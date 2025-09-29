import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import '../models/future_purchase.dart';
import '../models/transaction.dart';
import '../widgets/custom_button.dart';

class FuturePurchasesPage extends StatefulWidget {
  @override
  _FuturePurchasesPageState createState() => _FuturePurchasesPageState();
}

class _FuturePurchasesPageState extends State<FuturePurchasesPage> with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late Box<FuturePurchase> box;
  late Box<Transaction> walletBox;

  List<FuturePurchase> purchases = [];
  final assetsAudioPlayer = AssetsAudioPlayer();

  @override
  void initState() {
    super.initState();
    box = Hive.box<FuturePurchase>('futurePurchases');
    walletBox = Hive.box<Transaction>('transactions');
    purchases = box.values.toList();

    // Listen to box changes
    box.watch().listen((event) {
      setState(() {
        purchases = box.values.toList();
      });
    });
  }

  void _playSound() {
    try {
      assetsAudioPlayer.open(
        Audio("assets/sounds/click.mp3"), // فایل صوتی کوتاه باید در پوشه assets/sounds اضافه شود
        autoStart: true,
      );
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void _addItem(String name, int price) {
    final newItem = FuturePurchase(name: name, price: price);
    box.add(newItem);
    _listKey.currentState?.insertItem(purchases.length);
  }

  void _markBought(int index) {
    final item = purchases[index];
    if (item.bought) return;

    final totalSaved = walletBox.values.fold<int>(
        0, (sum, t) => t.amount > 0 ? sum + t.amount : sum);

    if (totalSaved >= item.price) {
      setState(() {
        item.bought = true;
      });
      item.save();
      walletBox.add(Transaction(
        title: 'خرید ${item.name}',
        amount: -item.price,
        date: DateTime.now(),
      ));

      _playSound();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حالا می‌تونی ${item.name} را بخری!')),
      );
    } else if (totalSaved >= 0.7 * item.price) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تقریباً به ${item.name} رسیدی، کمی پس‌انداز کن!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هنوز پول کافی برای ${item.name} نیست!')),
      );
    }
  }

  Widget _buildItem(BuildContext context, int index, Animation<double> animation) {
    final item = purchases[index];
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        color: item.bought ? Colors.grey.withOpacity(0.5) : Colors.orange.withOpacity(0.8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.symmetric(vertical: 6),
        child: ListTile(
          leading: Icon(
            item.bought ? Icons.check_circle : Icons.shopping_cart,
            color: Colors.white,
          ),
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.bought ? TextDecoration.lineThrough : null,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            "قیمت: ${item.price} تومان",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          trailing: CustomButton(
            text: item.bought ? "خرید شده" : "تیک خرید",
            color: item.bought ? Colors.grey : Colors.white70,
            onPressed: () {
              _markBought(index);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('لیست خریدهای آتی')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/minecraft.jpg',
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "نام آیتم",
                    fillColor: Colors.white70,
                    filled: true,
                  ),
                ),
                SizedBox(height: 12),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: "قیمت",
                    fillColor: Colors.white70,
                    filled: true,
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                CustomButton(
                  text: "افزودن به لیست",
                  color: Color(0xFFF28C28),
                  onPressed: () {
                    final name = _nameController.text.trim();
                    final price = int.tryParse(_priceController.text) ?? 0;
                    if (name.isEmpty || price <= 0) return;
                    _addItem(name, price);
                    _nameController.clear();
                    _priceController.clear();
                  },
                ),
                SizedBox(height: 16),
                Expanded(
                  child: purchases.isEmpty
                      ? Center(
                          child: Text(
                            'هیچ خرید آتی ثبت نشده',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : AnimatedList(
                          key: _listKey,
                          initialItemCount: purchases.length,
                          itemBuilder: (context, index, animation) => _buildItem(context, index, animation),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
