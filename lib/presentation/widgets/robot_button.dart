import 'package:flutter/material.dart';

class RobotButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final VoidCallback? onPressed;

  const RobotButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: const Size(60, 28),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}