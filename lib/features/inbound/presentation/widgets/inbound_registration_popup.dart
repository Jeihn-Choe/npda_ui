import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/constants/colors.dart';

import '../../../../presentation/widgets/form_field_widget.dart';
import 'inbound_registration_popup_viewmodel.dart';

class InboundRegistrationPopup extends ConsumerStatefulWidget {
  final String? scannedData;

  const InboundRegistrationPopup({super.key, this.scannedData});

  @override
  ConsumerState<InboundRegistrationPopup> createState() =>
      _InboundRegistrationPopupState();
}

class _InboundRegistrationPopupState
    extends ConsumerState<InboundRegistrationPopup> {
  @override
  void initState() {
    super.initState();

    // ViewModel 초기화 및 scannedData 설정
    Future.microtask(() {
      final viewModel = ref.read(inboundRegistrationPopupViewModelProvider);
      viewModel.initialize(); // ViewModel 초기화 호출

      // scannedData가 있을 때만 적용 (수동 팝업 열기의 경우 null)
      if (widget.scannedData != null && widget.scannedData!.isNotEmpty) {
        viewModel.applyScannedData(widget.scannedData!);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(inboundRegistrationPopupViewModelProvider);

    return AlertDialog(
      title: const Text(
        '입고 등록',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildFormFields(viewModel),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('취소', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await viewModel.saveInboundRegistration(ref, context);

              // 저장 후 팝업 닫기
              if (mounted) {
                Navigator.of(context).pop();
              }
            } catch (e) {
              // 에러 발생 시 다이얼로그로 알림
              if (mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Error'),
                    content: Text(e.toString().replaceFirst('Exception: ', '')),
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
      titlePadding: const EdgeInsets.fromLTRB(12.0, 16.0, 12.0, 0.0),
      contentPadding: const EdgeInsets.all(8.0),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
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
          label: 'HU Number',
          hintText: '바코드를 스캔하세요.',
        ),
        const SizedBox(height: 8),
        FormFieldWidget(
          controller: viewModel.sourceBinController,
          label: '출발지 가상빈 Number',
          hintText: '바코드를 스캔하세요.',
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '목적지 구역',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGrey,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Row(
                    children: [
                      Radio<int>(
                        value: 0,
                        groupValue: viewModel.destinationArea,
                        onChanged: (int? value) {
                          viewModel.setDestinationArea(value);
                        },
                        activeColor: AppColors.celltrionGreen,
                      ),
                      const Text('3층 지정구역'),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: viewModel.destinationArea,
                        onChanged: (int? value) {
                          viewModel.setDestinationArea(value);
                        },
                        activeColor: AppColors.celltrionGreen,
                      ),
                      const Text('3층 랙'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 1, 4, 1),
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
              const SizedBox(height: 3),
              DropdownButtonFormField<String>(
                value: viewModel.selectedRackLevel,
                hint: const Text(
                  '몇층으로 갈지 표시합니다.',
                  style: TextStyle(fontSize: 14, color: AppColors.grey600),
                ),
                onChanged: (String? newValue) {
                  viewModel.setSelectedRackLevel(newValue);
                },
                items: viewModel.rackLevels.map<DropdownMenuItem<String>>((
                  String value,
                ) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
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

        const SizedBox(height: 12),
        FormFieldWidget(
          controller: viewModel.userIdController,
          label: '사번',
          enabled: false,
        ),
      ],
    );
  }
}
