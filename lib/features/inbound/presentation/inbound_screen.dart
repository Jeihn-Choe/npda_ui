import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/presentation/widgets/form_card_layout.dart';
import 'package:npda_ui_flutter/presentation/widgets/info_field_widget.dart';

class InboundScreen extends ConsumerWidget {
  const InboundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Logger().d('LOG_DEBUG : InboundScreen build');

    return Container(
      color: Colors.grey.shade100,
      child: Padding(
        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
        child: Column(
          children: [
            /// 상단 버튼 바
            Container(
              padding: EdgeInsets.fromLTRB(25, 5, 25, 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                /// TODO: 삭제, 작업시작, 생성 버튼 (기능 구현 시 연결)
                children: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('삭제'),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.celltrionGreen,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(' 작업 시작 '),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade500,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('생성'),
                  ),
                ],
              ),
            ),

            /// 작업 Que 생성 시 표시, 평소에는 invisible 처리
            FormCardLayout(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InfoFieldWidget(filedName: '작업 Que', fieldValue: ''),
                      ],
                    ),
                  ),
                  SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      children: [
                        InfoFieldWidget(filedName: '등록자', fieldValue: ''),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 중앙 오더 상세 표시
            FormCardLayout(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        InfoFieldWidget(filedName: 'No.', fieldValue: ''),
                        InfoFieldWidget(filedName: '제품정보', fieldValue: ''),
                      ],
                    ),
                  ),
                  SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      children: [
                        InfoFieldWidget(filedName: '작업 시간', fieldValue: ''),
                        InfoFieldWidget(filedName: '랩핑', fieldValue: ''),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            /// 하단 데이터그리드 상세 표시
            FormCardLayout(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // _buildInfoField(String fieldName, [String? fieldValue]) {
  //   return Padding(
  //     padding: EdgeInsets.all(4),
  //
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [InfoFieldWidget(filedName: 'No.', fieldValue: '')],
  //     ),

  // child: Column(
  //   crossAxisAlignment: CrossAxisAlignment.start,
  //   children: [
  //     Text(
  //       textAlign: TextAlign.left,
  //       '$fieldName: ',
  //       style: TextStyle(
  //         fontSize: 14,
  //         color: AppColors.darkGrey,
  //         fontWeight: FontWeight.bold,
  //       ),
  //     ),
  //     Container(
  //       width: double.infinity,
  //       padding: EdgeInsets.all(8),
  //       decoration: BoxDecoration(
  //         border: Border.all(color: AppColors.grey300),
  //         borderRadius: BorderRadius.circular(8),
  //         color: AppColors.grey100,
  //       ),
  //       child: Text(
  //         textAlign: TextAlign.left,
  //         fieldValue ?? '-',
  //         style: TextStyle(
  //           fontSize: 14,
  //           color: AppColors.black,
  //           fontWeight: FontWeight.normal,
  //         ),
  //       ),
  //     ),
  //   ],
  // ),
  // );
  // }
}
