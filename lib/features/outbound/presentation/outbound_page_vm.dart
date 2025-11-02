import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

// 1. State 클래스
@immutable
class OutboundPageState extends Equatable {
  final bool showOutboundPopup;
  final String? scannedDataForPopup;

  const OutboundPageState({
    // ✨ 이름 변경
    this.showOutboundPopup = false,
    this.scannedDataForPopup,
  });

  OutboundPageState copyWith({
    // ✨ 이름 변경
    bool? showOutboundPopup,
    String? scannedDataForPopup,
  }) {
    return OutboundPageState(
      // ✨ 이름 변경
      showOutboundPopup: showOutboundPopup ?? this.showOutboundPopup,
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,
    );
  }

  @override
  List<Object?> get props => [showOutboundPopup, scannedDataForPopup];
}

// 2. ViewModel 클래스
class OutboundPageVm extends StateNotifier<OutboundPageState> {
  // ✨ 이름 변경
  final Ref _ref;

  OutboundPageVm(this._ref) : super(const OutboundPageState()); // ✨ 이름 변경

  // 스캔된 데이터 처리/ 팝업 호출 메서드
  void handleScannedData(String scannedData) {
    appLogger.d("아웃바운드 ViewModel handleScannedData 호출: $scannedData");

    final isScannerModeActive = _ref.read(scannerViewModelProvider);

    if (isScannerModeActive) {
      state = state.copyWith(
        showOutboundPopup: true,
        scannedDataForPopup: scannedData,
      );
    } else {
      appLogger.d("스캐너 모드가 비활성화되어 스캔 입력을 무시합니다.");
    }
  }

  // 팝업 제어 관련 메소드
  void showCreationPopup() {
    state = state.copyWith(showOutboundPopup: true, scannedDataForPopup: null);
  }

  void closeCreationPopup() {
    state = state.copyWith(showOutboundPopup: false, scannedDataForPopup: null);
  }
}

// 3. Provider
final outboundPageVMProvider =
    StateNotifierProvider<OutboundPageVm, OutboundPageState>((ref) {
      return OutboundPageVm(ref);
    });
