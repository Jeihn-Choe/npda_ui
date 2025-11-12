import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';

/// State ---> UI 상태만
class InboundPageState extends Equatable {
  final String? firstScannedData;
  final String? secondScannedData;
  final bool showInboundPopup;

  const InboundPageState({
    this.firstScannedData,
    this.secondScannedData,
    this.showInboundPopup = false,
  });

  InboundPageState copyWith({
    String? firstScannedData,
    String? secondScannedData,
    bool? showInboundPopup,
  }) {
    return InboundPageState(
      firstScannedData: firstScannedData ?? this.firstScannedData,
      secondScannedData: secondScannedData ?? this.secondScannedData,
      showInboundPopup: showInboundPopup ?? this.showInboundPopup,
    );
  }

  @override
  List<Object?> get props => [
    firstScannedData,
    secondScannedData,
    showInboundPopup,
  ];
}

/// ViewModel --> UI 로직만
class InboundPageVm extends StateNotifier<InboundPageState> {
  final Ref _ref;

  InboundPageVm(this._ref) : super(const InboundPageState());

  /// 스캔 없이 수동으로 팝업 열기
  void openPopupManually() {
    state = state.copyWith(
      firstScannedData: null,
      secondScannedData: null,
      showInboundPopup: true,
    );
  }

  /// 스캔 데이터 처리
  void handleScannedData(String scannedData) {
    final isScannerModeActive = _ref.read(scannerViewModelProvider);
    if (!isScannerModeActive) return;

    // 팝업이 닫혀있으면 첫 번째 스캔으로 팝업 오픈
    if (!state.showInboundPopup) {
      state = state.copyWith(
        firstScannedData: scannedData,
        showInboundPopup: true,
      );
      return;
    }

    // 팝업이 이미 열려있으면 ViewModel에 데이터 전달
    final popupViewModel = _ref.read(inboundRegistrationPopupViewModelProvider);
    popupViewModel.applyScannedData(scannedData);

    // 두 필드가 모두 채워지면 포커스 해제 신호
    if (popupViewModel.areBothFieldsFilled()) {
      state = state.copyWith(secondScannedData: scannedData);
    }
  }

  void clearInboundPopup() {
    state = state.copyWith(
      firstScannedData: null,
      secondScannedData: null,
      showInboundPopup: false,
    );
  }

  void setInboundPopupState(bool isShowing) {
    state = state.copyWith(showInboundPopup: isShowing);
  }
}
