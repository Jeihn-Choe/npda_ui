import 'package:flutter/cupertino.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

class InfoFieldWidget extends StatelessWidget {
  final String filedName;
  final String fieldValue;

  const InfoFieldWidget({
    super.key,
    required this.filedName,
    required this.fieldValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8, 4, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            textAlign: TextAlign.left,
            '$filedName: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              border: Border.all(color: AppColors.grey300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              textAlign: TextAlign.center,
              fieldValue ?? '-',
              style: TextStyle(
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
