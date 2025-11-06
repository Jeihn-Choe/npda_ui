import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScannerViewModel extends StateNotifier<bool> {
  ScannerViewModel() : super(true);

  void toggleScannerMode() {
    state = !state;
  }
}

final scannerViewModelProvider = StateNotifierProvider<ScannerViewModel, bool>((
  ref,
) {
  return ScannerViewModel();
});
