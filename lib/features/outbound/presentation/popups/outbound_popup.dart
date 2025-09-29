import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'outbound_popup_vm.dart';

class OutboundPopup extends ConsumerStatefulWidget {
  // 이전 화면(outbound_screen)에서 스캔된 데이터를 전달받기 위한 변수
  final String? scannedData;

  const OutboundPopup({super.key, this.scannedData});

  @override
  ConsumerState<OutboundPopup> createState() => _OutboundPopupState();
}

class _OutboundPopupState extends ConsumerState<OutboundPopup> {
  @override
  void initState() {
    super.initState();
    // 위젯이 처음 생성될 때, ViewModel의 초기화 메소드를 호출합니다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(outboundPopupVMProvider.notifier).initializeFromScan(widget.scannedData);
    });
  }

  @override
  Widget build(BuildContext context) {
    // 팝업의 상태를 구독(watch)하여, TextField에 현재 값을 표시합니다.
    final popupState = ref.watch(outboundPopupVMProvider);

    return AlertDialog(
      title: const Text('출고 오더 생성'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            // 상태에 있는 doNo 값을 컨트롤러에 표시
            controller: TextEditingController(text: popupState.doNo),
            onChanged: (value) {
              // 값이 변경될 때마다 ViewModel의 메소드를 호출하여 상태를 업데이트
              ref.read(outboundPopupVMProvider.notifier).updateDoNo(value);
            },
            decoration: const InputDecoration(
              labelText: 'DO No.',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            // 상태에 있는 savedBinNo 값을 컨트롤러에 표시
            controller: TextEditingController(text: popupState.savedBinNo),
            onChanged: (value) {
              // 값이 변경될 때마다 ViewModel의 메소드를 호출하여 상태를 업데이트
              ref
                  .read(outboundPopupVMProvider.notifier)
                  .updateSavedBinNo(value);
            },
            decoration: const InputDecoration(
              labelText: '저장빈 No.',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // '취소' 버튼: 단순히 팝업을 닫습니다.
            Navigator.of(context).pop();
          },
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: () {
            // '저장' 버튼: ViewModel의 saveOrder 메소드를 호출하고 팝업을 닫습니다.
            ref.read(outboundPopupVMProvider.notifier).saveOrder();
            Navigator.of(context).pop();
          },
          child: const Text('저장'),
        ),
      ],
    );
  }
}
