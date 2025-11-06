import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';

// 1. State 클래스 (UI 상태만 남김)
class InboundPageState extends Equatable {
  final String? scannedDataForPopup;
  final bool showInboundPopup;

  const InboundPageState({
    this.scannedDataForPopup,
    this.showInboundPopup = false,
  });

  InboundPageState copyWith({
    String? scannedDataForPopup,
    bool? showInboundPopup,
  }) {
    return InboundPageState(
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,
      showInboundPopup: showInboundPopup ?? this.showInboundPopup,
    );
  }

  @override
  List<Object?> get props => [scannedDataForPopup, showInboundPopup];
}

// 2. ViewModel 클래스 (UI 로직만 남김)
class InboundPageVm extends StateNotifier<InboundPageState> {
  final Ref _ref;

  InboundPageVm(this._ref) : super(const InboundPageState());

  void handleScannedData(String scannedData) {
    final isScannerModeActive = _ref.read(scannerViewModelProvider);
    if (isScannerModeActive) {
      state = state.copyWith(
        scannedDataForPopup: scannedData,
        showInboundPopup: true,
      );
    }
  }

  void clearInboundPopup() {
    state = state.copyWith(scannedDataForPopup: null, showInboundPopup: false);
  }

  void setInboundPopupState(bool isShowing) {
    state = state.copyWith(showInboundPopup: isShowing);
  }
}
