import 'package:flutter/material.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

class FormCardLayout extends StatelessWidget {
  final Widget child;
  final double verticalMargin;
  final double keyboardVerticalMargin;
  final double contentPadding;
  final double keyboardContentPadding;
  final Color? backgroundColor;

  const FormCardLayout({
    super.key,
    required this.child,
    this.verticalMargin = 4,
    this.keyboardVerticalMargin = 8,
    this.contentPadding = 4,
    this.keyboardContentPadding = 8,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Center(
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          horizontal: 8,
          vertical: isKeyboardVisible ? keyboardVerticalMargin : verticalMargin,
        ),

        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(90),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(
            isKeyboardVisible ? keyboardContentPadding : contentPadding,
          ),
          child: child,
        ),
      ),
    );
  }
}
