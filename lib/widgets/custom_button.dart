import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onPressed;

  const CustomButton({
    Key? key,
    required this.text,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52, // ارتفاع دکمه
      width: double.infinity, // عرض کامل
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // گوشه‌های گرد
          ),
          textStyle: const TextStyle(
            fontFamily: 'Shabnam',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.black, // رنگ متن اصلی
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(offset: Offset(2, 2), color: Colors.white),
              Shadow(offset: Offset(-2, 2), color: Colors.white),
              Shadow(offset: Offset(2, -2), color: Colors.white),
              Shadow(offset: Offset(-2, -2), color: Colors.white),
              Shadow(offset: Offset(2, 0), color: Colors.white),
              Shadow(offset: Offset(-2, 0), color: Colors.white),
              Shadow(offset: Offset(0, 2), color: Colors.white),
              Shadow(offset: Offset(0, -2), color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
