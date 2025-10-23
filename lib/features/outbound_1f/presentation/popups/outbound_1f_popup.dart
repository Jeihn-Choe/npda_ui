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
  late final TextEditingController _doNoController;
  late final TextEditingController _savedBinNoController;
  late final TextEditingController _startTimeController;
  late final TextEditingController _userIdController;

  late final VoidCallback _doNoListener;
  late final VoidCallback _savedBinNoListener;

  @override
  void initState() {
    super.initState();

    _doNoController = TextEditingController();
    _savedBinNoController = TextEditingController();
    _startTimeController = TextEditingController();
    _userIdController = TextEditingController();

    _doNoListener = () {
      if (ref.read(outbound1FPopupVMProvider).doNo != _doNoController.text) {
        ref
            .read(outbound1FPopupVMProvider.notifier)
            .onDoNoChanged(_doNoController.text);
      }
    };
    _savedBinNoListener = () {
      if (ref.read(outbound1FPopupVMProvider).savedBinNo !=
          _savedBinNoController.text) {
        ref
            .read(outbound1FPopupVMProvider.notifier)
            .onSavedBinNoChanged(_savedBinNoController.text);
      }
    };

    _doNoController.addListener(_doNoListener);
    _savedBinNoController.addListener(_savedBinNoListener);

    Future.microtask(
      () => ref
          .read(outbound1FPopupVMProvider.notifier)
          .initialize(scannedData: widget.scannedData, userId: '12345'),
    );
  }

  @override
  void dispose() {
    _doNoController.removeListener(_doNoListener);
    _savedBinNoController.removeListener(_savedBinNoListener);

    _doNoController.dispose();
    _savedBinNoController.dispose();
    _startTimeController.dispose();
    _userIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Outbound1FPopupState>(outbound1FPopupVMProvider, (previous, next) {
      if (next.doNo != _doNoController.text) {
        _doNoController.text = next.doNo;
      }
      if (next.savedBinNo != _savedBinNoController.text) {
        _savedBinNoController.text = next.savedBinNo;
      }
      final formattedTime = next.startTime?.toString().substring(0, 19) ?? '';
      if (formattedTime != _startTimeController.text) {
        _startTimeController.text = formattedTime;
      }
      if (next.userId != null && next.userId != _userIdController.text) {
        _userIdController.text = next.userId!;
      }
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(next.error!), backgroundColor: Colors.red),
          );
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
        width: MediaQuery.of(context).size.width * 0.75,
        height: MediaQuery.of(context).size.height * 0.65,
        child: Stack(
          children: [
            SingleChildScrollView(child: _buildFormFields()),
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
                  final success = await ref
                      .read(outbound1FPopupVMProvider.notifier)
                      .saveOrder();
                  if (success && mounted) {
                    Navigator.of(context).pop();
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormFieldWidget(
          controller: _doNoController,
          label: 'DO No.',
          hintText: 'DO No.를 입력하거나 스캔하세요.',
        ),
        const SizedBox(height: 12),
        FormFieldWidget(
          controller: _savedBinNoController,
          label: '저장빈',
          hintText: '저장빈을 입력하거나 스캔하세요.',
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
}
