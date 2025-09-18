import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../../presentation/widgets/form_field_widget.dart';
import '../providers/inbound_providers.dart';

class InboundRegistrationPopup extends ConsumerStatefulWidget {
  const InboundRegistrationPopup({super.key});

  @override
  ConsumerState<InboundRegistrationPopup> createState() =>
      _InboundRegistrationPopupState();
}

class _InboundRegistrationPopupState
    extends ConsumerState<InboundRegistrationPopup> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(inboundRegistrationPopupViewModelProvider);

    return AlertDialog(
      title: const Text(
        '입고 등록',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.65,
        child: SingleChildScrollView(child: _buildFormFields(viewModel)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: () async {
            logger('저장 버튼 클릭됨');

            try {
              await viewModel.saveInboundRegistration(ref);

              // 저장 후 팝업 닫기
              if (mounted) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              // 에러 발생 시 다이얼로그로 알림
              if (mounted) {
                logger(e.toString());

                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('오류'),
                    content: Text(e.toString()),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('확인'),
                      ),
                    ],
                  ),
                );
              }
            }
          },
          child: const Text('저장', style: TextStyle(fontSize: 14)),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 0.0),
      contentPadding: const EdgeInsets.all(12.0),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
    );
  }

  Widget _buildFormFields(var viewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormFieldWidget(
          controller: viewModel.pltCodeController,
          label: 'PLT Number',
          hintText: '바코드를 스캔하세요.',
        ),
        const SizedBox(height: 12),
        FormFieldWidget<DateTime>(
          controller: viewModel.workTimeController,
          label: '작업시간',
          initialValue: DateTime.now().toUtc().add(const Duration(hours: 9)),
          keyboardType: TextInputType.datetime,
          readOnly: true,
          onTap: () => _selectDateTime(context),
          valueToString: (dateTime) => dateTime.toString().substring(0, 19),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '제품정보 (규격/ 단수)',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 4),
              DropdownButtonFormField<String>(
                value: viewModel.selectedRackLevel,
                hint: const Text(
                  '몇층으로 갈지 표시합니다.',
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    viewModel.setSelectedRackLevel(newValue);
                  });
                },
                items: <String>['1단 - 001', '2단 - 002', '3단 - 003', '기준없음']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    })
                    .toList(),
                decoration: InputDecoration(
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
                  filled: true,
                  fillColor: AppColors.grey100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        FormFieldWidget(
          controller: viewModel.userIdController,
          label: '사번',
          enabled: false,
        ),
      ],
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime selectedDate = DateTime.now().toUtc().add(
      const Duration(hours: 9),
    );

    await showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 250,
        child: CupertinoDatePicker(
          mode: CupertinoDatePickerMode.dateAndTime,
          initialDateTime: selectedDate,
          onDateTimeChanged: (DateTime newDate) {
            selectedDate = newDate;
          },
        ),
      ),
    );
  }
}
