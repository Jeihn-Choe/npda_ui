import 'package:flutter/material.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

class FormFieldWidget<T> extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hintText;
  final int maxLines;
  final bool obscureText;
  final bool enabled;
  final T? initialValue;
  final String Function(T)? valueToString;
  final VoidCallback? onTap;
  final bool readOnly;

  const FormFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.hintText,
    this.maxLines = 1,
    this.obscureText = false,
    this.enabled = true,
    this.initialValue,
    this.valueToString,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    if (initialValue != null && controller.text.isEmpty) {
      if (valueToString != null) {
        controller.text = valueToString!(initialValue as T);
      } else if (initialValue is String) {
        controller.text = initialValue as String;
      } else {
        controller.text = initialValue.toString();
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.left,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 3),
          // TextField with decoration copied from CustomTextField for visual consistency
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            obscureText: obscureText,
            enabled: enabled,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
              // Decoration from CustomTextField
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.celltrionGreen,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.grey300),
              ),
              filled: true,
              fillColor: AppColors.grey100,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
