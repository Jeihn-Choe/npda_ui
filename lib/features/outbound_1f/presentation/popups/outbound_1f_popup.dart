import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/presentation/widgets/form_field_widget.dart';

import 'outbound_1f_popup_vm.dart';

class Outbound1FPopup extends ConsumerStatefulWidget {
  final String? scannedData;

  const Outbound1FPopup({super.key, this.scannedData});

  @override
  ConsumerState<Outbound1FPopup> createState() => _Outbound1FPopupState();
}

class _Outbound1FPopupState extends ConsumerState<Outbound1FPopup> {
  // TODO: 스캔 기능을 위해 컴트롤러 유지
  late final TextEditingController _doNoController;
  late final TextEditingController _savedBinNoController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _userIdController;
  late final TextEditingController _quantityController;

  // TODO: 스캔 기능을 위해 리스너 유지
  late final VoidCallback _doNoListener;
  late final VoidCallback _savedBinNoListener;
  late final VoidCallback _quantityListener;

  @override
  void initState() {
    super.initState();

    _doNoController = TextEditingController();
    _savedBinNoController = TextEditingController();
    _startTimeController = TextEditingController();
    _userIdController = TextEditingController();
    _quantityController = TextEditingController(text: '1');

    // TODO: 스캔 기능이 추가될 때 주석 해제
    // _doNoListener = () {
    //   if (ref.read(outbound1FPopupVMProvider).sourceArea != _doNoController.text) {
    //     ref
    //         .read(outbound1FPopupVMProvider.notifier)
    //         .onSourceAreaChanged(_doNoController.text);
    //   }
    // };
    // _savedBinNoListener = () {
    //   if (ref.read(outbound1FPopupVMProvider).destinationArea !=
    //       _savedBinNoController.text) {
    //     ref
    //         .read(outbound1FPopupVMProvider.notifier)
    //         .onDestinationAreaChanged(_savedBinNoController.text);
    //   }
    // };

    // 수량 입력 리스너
    _quantityListener = () {
      final quantity = int.tryParse(_quantityController.text) ?? 1;
      if (ref.read(outbound1FPopupVMProvider).quantity != quantity) {
        ref
            .read(outbound1FPopupVMProvider.notifier)
            .onQuantityChanged(quantity);
      }
    };

    // _doNoController.addListener(_doNoListener);
    // _savedBinNoController.addListener(_savedBinNoListener);
    _quantityController.addListener(_quantityListener);

    Future.microtask(
      () => ref
          .read(outbound1FPopupVMProvider.notifier)
          .initialize(scannedData: widget.scannedData, userId: '12345'),
    );
  }

  @override
  void dispose() {
    // TODO: 스캔 기능이 추가될 때 주석 해제
    // _doNoController.removeListener(_doNoListener);
    // _savedBinNoController.removeListener(_savedBinNoListener);
    _quantityController.removeListener(_quantityListener);

    _doNoController.dispose();
    _savedBinNoController.dispose();
    _startTimeController.dispose();
    _userIdController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Outbound1FPopupState>(outbound1FPopupVMProvider, (
      previous,
      next,
    ) {
      // TODO: 스캔 기능이 추가될 때 주석 해제
      // if (next.startArea != _doNoController.text) {
      //   _doNoController.text = next.startArea;
      // }
      // if (next.destinationArea != _savedBinNoController.text) {
      //   _savedBinNoController.text = next.destinationArea;
      // }

      final formattedTime = next.startTime?.toString().substring(0, 19) ?? '';
      if (formattedTime != _startTimeController.text) {
        _startTimeController.text = formattedTime;
      }
      if (next.userId != null && next.userId != _userIdController.text) {
        _userIdController.text = next.userId!;
      }
      if (next.quantity.toString() != _quantityController.text) {
        _quantityController.text = next.quantity.toString();
      }
    });

    final isLoading = ref.watch(
      outbound1FPopupVMProvider.select((s) => s.isLoading),
    );

    return AlertDialog(
      title: const Text(
        '출고 등록 (1F)',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: _buildFormFields(),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('취소', style: TextStyle(fontSize: 14)),
        ),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () async {
                  try {
                    final success = await ref
                        .read(outbound1FPopupVMProvider.notifier)
                        .saveOrder();
                    if (success && mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    // 에러 발생 시 다이얼로그로 알림
                    if (mounted) {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          title: const Text('입력 확인'),
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
      titlePadding: const EdgeInsets.fromLTRB(12.0, 24.0, 12.0, 0.0),
      contentPadding: const EdgeInsets.all(12.0),
      actionsPadding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
    );
  }

  Widget _buildFormFields() {
    final state = ref.watch(outbound1FPopupVMProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 출발지역 드롭다운
        _buildDropdownField(
          label: '출발지역',
          value: state.sourceArea.isEmpty ? null : state.sourceArea,
          items: state.availableSourceAreas,
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(outbound1FPopupVMProvider.notifier)
                  .onSourceAreaChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        // 목적지역 드롭다운
        _buildDropdownField(
          label: '목적지역',
          value: state.destinationArea.isEmpty ? null : state.destinationArea,
          items: state.availableDestinationAreas,
          onChanged: (value) {
            if (value != null) {
              ref
                  .read(outbound1FPopupVMProvider.notifier)
                  .onDestinationAreaChanged(value);
            }
          },
        ),
        const SizedBox(height: 12),
        // 수량 입력
        FormFieldWidget(
          controller: _quantityController,
          label: '수량',
          hintText: '이동할 수량을 입력하세요',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        FormFieldWidget(
          controller: _startTimeController,
          label: '작업시간',
          readOnly: true,
        ),
        const SizedBox(height: 12),
        FormFieldWidget(
          controller: _userIdController,
          label: '사번',
          enabled: false,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('${label}을 선택하세요'),
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
