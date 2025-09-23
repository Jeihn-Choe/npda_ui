import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../utils/logger.dart';

class ScannerViewModel extends StateNotifier<bool> {
  ScannerViewModel() : super(true);

  void toggleScannerMode() {
    state = !state;

    logger("스캐너모드 토글상태 : $state");
  }
}

final scannerViewModelProvider = StateNotifierProvider<ScannerViewModel, bool>((
  ref,
) {
  return ScannerViewModel();
});
