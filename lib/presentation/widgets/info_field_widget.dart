import 'package:flutter/cupertino.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

class InfoFieldWidget extends StatelessWidget {
  final String fieldName;
  final String? fieldValue;

  const InfoFieldWidget({
    super.key,
    required this.fieldName,
    this.fieldValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$fieldName: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              textAlign: TextAlign.center,
              fieldValue ?? '-',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}