import 'package:flutter/material.dart';

class CardWidget extends StatelessWidget {
  final String title;
  final int amount;

  CardWidget({required this.title, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.5), // پس‌زمینه شفاف
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Center(
          child: Text(
            '$title: $amount تومان',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
