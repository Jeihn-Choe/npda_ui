import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';
import 'package:npda_ui_flutter/features/login/presentation/login_viewmodel.dart';

import '../../../../presentation/widgets/form_field_widget.dart';

class InboundRegistrationPopup extends ConsumerStatefulWidget {
  const InboundRegistrationPopup({super.key});

  @override
  ConsumerState<InboundRegistrationPopup> createState() =>
      _InboundRegistrationPopupState();
}

class _InboundRegistrationPopupState
    extends ConsumerState<InboundRegistrationPopup> {
  late final TextEditingController _itemCodeController;
  late final TextEditingController _itemNameController;
  late final TextEditingController _remarksController;
  String? _selectedRackLevel;

  @override
  void initState() {
    super.initState();
    _itemCodeController = TextEditingController();
    _itemNameController = TextEditingController();
    _remarksController = TextEditingController();
  }

  @override
  void dispose() {
    _itemCodeController.dispose();
    _itemNameController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // loginViewModelProvider 구독
    final loginState = ref.watch(loginViewModelProvider);

    return AlertDialog(
      title: const Text(
        '신규 입고 품목 등록',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.55,
        child: SingleChildScrollView(child: _buildFormFields(loginState)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: 저장 로직 구현 (로그인 정보 사용: loginState.user)
            Navigator.of(context).pop();
          },
          child: const Text('저장', style: TextStyle(fontSize: 14)),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 10.0),
      contentPadding: const EdgeInsets.all(24.0),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
    );
  }

  Widget _buildFormFields(dynamic loginState) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormFieldWidget(
          controller: _itemCodeController,
          label: 'PLT Number',
          hintText: '바코드를 스캔하세요.',
        ),
        const SizedBox(height: 12),
        FormFieldWidget<DateTime>(
          controller: _itemNameController,
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
                value: _selectedRackLevel,
                hint: const Text(
                  '몇층으로 갈지 표시합니다.',
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRackLevel = newValue;
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
          controller: _remarksController,
          label: '사번',
          enabled: false,
          initialValue: loginState.userId,
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

    setState(() {
      _itemNameController.text = selectedDate.toString().substring(0, 19);
    });
  }
}
