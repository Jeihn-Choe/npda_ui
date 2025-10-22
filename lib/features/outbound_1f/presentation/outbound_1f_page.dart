import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/presentation/main_shell.dart';

class Outbound1fPage extends ConsumerStatefulWidget {
  const Outbound1fPage({super.key});

  @override
  ConsumerState<Outbound1fPage> createState() => _Outbound1fPage();
}

class _Outbound1fPage extends ConsumerState<Outbound1fPage> {
  late FocusNode _scannerFocusNode;
  late TextEditingController _scannerTextController;

  @override
  void initState() {
    super.initState();
    _scannerFocusNode = FocusNode();
    _scannerTextController = TextEditingController();

    _scannerFocusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final currentTabIndex = ref.read(mainShellTabIndexProvider);
    if (currentTabIndex != 2) return;

    // TODO: vm 세팅되면 주석해제
    // final outbound1fState = ref.read(outbound1fVMProvider);
    // if (!_scannerFocusNode.hasFocus && !outbound1fState.showOutboundPopup) {
    //   FocusScope.of(context).requestFocus(_scannerFocusNode);
    //   appLogger.d("outbound 1f 포커스 다시 가져옴");
    // }
  }

  @override
  void dispose() {
    _scannerFocusNode.removeListener(_onFocusChange);
    _scannerFocusNode.dispose();
    _scannerTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SingleChildScrollView());
  }
}
