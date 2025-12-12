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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 터치 영역 최소화 (여백 제거)
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
