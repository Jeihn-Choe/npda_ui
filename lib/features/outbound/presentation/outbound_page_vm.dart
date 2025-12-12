import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/features/status/presentation/providers/robot_status_provider.dart';

import '../../status/domain/entities/robot_status_entity.dart';
import '../../status/presentation/providers/status_dependency_provider.dart';

// 1. State 클래스
@immutable
class OutboundPageState extends Equatable {
  final bool showOutboundPopup;
  final String? scannedDataForPopup;

  final RobotStatusEntity ssrStatus;
  final RobotStatusEntity spt1fStatus;
  final RobotStatusEntity spt3fStatus;

  const OutboundPageState({
    this.showOutboundPopup = false,
    this.scannedDataForPopup,

    required this.ssrStatus,
    required this.spt1fStatus,
    required this.spt3fStatus,
  });

  OutboundPageState copyWith({
    bool? showOutboundPopup,
    String? scannedDataForPopup,

    RobotStatusEntity? ssrStatus,
    RobotStatusEntity? spt1fStatus,
    RobotStatusEntity? spt3fStatus,
  }) {
    return OutboundPageState(
      showOutboundPopup: showOutboundPopup ?? this.showOutboundPopup,
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,

      ssrStatus: ssrStatus ?? this.ssrStatus,
      spt1fStatus: spt1fStatus ?? this.spt1fStatus,
      spt3fStatus: spt3fStatus ?? this.spt3fStatus,
    );
  }

  @override
  List<Object?> get props => [
    showOutboundPopup,
    scannedDataForPopup,
    ssrStatus,
    spt1fStatus,
    spt3fStatus,
  ];
}

// 2. ViewModel 클래스
class OutboundPageVm extends StateNotifier<OutboundPageState> {
  final Ref _ref;

  OutboundPageVm(this._ref)
    : super(
        OutboundPageState(
          //초기 로봇 상태 설정
          ssrStatus: _ref.read(robotStatusProvider).ssrStatus,
          spt1fStatus: _ref.read(robotStatusProvider).spt1fStatus,
          spt3fStatus: _ref.read(robotStatusProvider).spt3fStatus,
        ),
      ) {
    _init();
  }

  void _init() {
    // 로봇 상태 구독 설정
    _ref.listen<RobotStatusState>(robotStatusProvider, (previous, next) {
      state = state.copyWith(
        ssrStatus: next.ssrStatus,
        spt1fStatus: next.spt1fStatus,
        spt3fStatus: next.spt3fStatus,
      );
    });
  }

  // 스캔된 데이터 처리/ 팝업 호출 메서드
  void handleScannedData(String scannedData) {
    final isScannerModeActive = _ref.read(scannerViewModelProvider);

    if (isScannerModeActive) {
      state = state.copyWith(
        showOutboundPopup: true,
        scannedDataForPopup: scannedData,
      );
    }
  }

  // 팝업 제어 관련 메소드
  void showCreationPopup() {
    state = state.copyWith(showOutboundPopup: true, scannedDataForPopup: null);
  }

  void closeCreationPopup() {
    state = state.copyWith(showOutboundPopup: false, scannedDataForPopup: null);
  }

  // [로봇 관련 메서드]
  Future<void> pauseResumeRobot(RobotStatusEntity robot) async {
    await _ref.read(robotControlUseCaseProvider).call(robot);
  }
}

// 3. Provider
final outboundPageVMProvider =
    StateNotifierProvider<OutboundPageVm, OutboundPageState>((ref) {
      return OutboundPageVm(ref);
    });
