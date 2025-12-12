import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/widgets/inbound_registration_popup_viewmodel.dart'; // import 경로 수정
import 'package:npda_ui_flutter/features/status/domain/entities/robot_status_entity.dart';
import 'package:npda_ui_flutter/features/status/presentation/providers/robot_status_provider.dart';

/// State ---> UI 상태만
class InboundPageState extends Equatable {
  final String? firstScannedData;
  final String? secondScannedData;
  final bool showInboundPopup;

  // ✨ 로봇 상태 필드 추가
  final RobotStatusEntity? ssrStatus;
  final RobotStatusEntity? spt1fStatus;
  final RobotStatusEntity? spt3fStatus;

  const InboundPageState({
    this.firstScannedData,
    this.secondScannedData,
    this.showInboundPopup = false,
    this.ssrStatus,
    this.spt1fStatus,
    this.spt3fStatus,
  });

  InboundPageState copyWith({
    String? firstScannedData,
    String? secondScannedData,
    bool? showInboundPopup,
    RobotStatusEntity? ssrStatus,
    RobotStatusEntity? spt1fStatus,
    RobotStatusEntity? spt3fStatus,
  }) {
    return InboundPageState(
      firstScannedData: firstScannedData ?? this.firstScannedData,
      secondScannedData: secondScannedData ?? this.secondScannedData,
      showInboundPopup: showInboundPopup ?? this.showInboundPopup,
      ssrStatus: ssrStatus ?? this.ssrStatus,
      spt1fStatus: spt1fStatus ?? this.spt1fStatus,
      spt3fStatus: spt3fStatus ?? this.spt3fStatus,
    );
  }

  @override
  List<Object?> get props => [
    firstScannedData,
    secondScannedData,
    showInboundPopup,
    ssrStatus,
    spt1fStatus,
    spt3fStatus,
  ];
}

/// ViewModel --> UI 로직만
class InboundPageVm extends StateNotifier<InboundPageState> {
  final Ref _ref;

  InboundPageVm(this._ref)
    : super(
        InboundPageState(
          // ✨ 초기 로봇 상태 설정
          ssrStatus: _ref.read(robotStatusProvider).ssrStatus,
          spt1fStatus: _ref.read(robotStatusProvider).spt1fStatus,
          spt3fStatus: _ref.read(robotStatusProvider).spt3fStatus,
        ),
      ) {
    _init();
  }

  void _init() {
    // ✨ 로봇 상태 구독
    _ref.listen<RobotStatusState>(robotStatusProvider, (previous, next) {
      state = state.copyWith(
        ssrStatus: next.ssrStatus,
        spt1fStatus: next.spt1fStatus,
        spt3fStatus: next.spt3fStatus,
      );
    });
  }

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

final inboundPageVMProvider =
    StateNotifierProvider<InboundPageVm, InboundPageState>((ref) {
      return InboundPageVm(ref);
    });
