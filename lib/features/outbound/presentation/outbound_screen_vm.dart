import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

// ✨ 1. 최종적으로 정리된 State 클래스
@immutable
class OutboundScreenState extends Equatable {
  final bool showOutboundPopup;
  final String? scannedDataForPopup;

  const OutboundScreenState({
    this.showOutboundPopup = false,
    this.scannedDataForPopup,
  });

  OutboundScreenState copyWith({
    bool? showOutboundPopup,
    String? scannedDataForPopup,
  }) {
    return OutboundScreenState(
      showOutboundPopup: showOutboundPopup ?? this.showOutboundPopup,
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,
    );
  }

  @override
  List<Object?> get props => [showOutboundPopup, scannedDataForPopup];
}

// ✨ 2. 최종적으로 정리된 ViewModel 클래스
class OutboundScreenVm extends StateNotifier<OutboundScreenState> {
  final Ref _ref;

  OutboundScreenVm(this._ref) : super(const OutboundScreenState());

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

// ✨ 3. 최종적으로 정리된 Provider
final outboundScreenViewModelProvider =
    StateNotifierProvider<OutboundScreenVm, OutboundScreenState>((ref) {
  return OutboundScreenVm(ref);
});
