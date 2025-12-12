import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/features/status/domain/entities/robot_status_entity.dart';

import '../../status/presentation/providers/robot_status_provider.dart';
import '../../status/presentation/providers/status_dependency_provider.dart';
import '../domain/entities/outbound_1f_sm_entity.dart';

class Outbound1fState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  // 화면 전체에 대한 상태만 남김
  final bool showOutboundPopup;
  final String? scannedDataForPopup;
  final Outbound1fSmEntity? selectedMission; // 상세 정보 표시에 사용

  final RobotStatusEntity? ssrStatus;
  final RobotStatusEntity? spt1fStatus;
  final RobotStatusEntity? spt3fStatus;

  const Outbound1fState({
    this.isLoading = false,
    this.errorMessage,
    this.showOutboundPopup = false,
    this.scannedDataForPopup,
    this.selectedMission,
    this.ssrStatus,
    this.spt1fStatus,
    this.spt3fStatus,
  });

  Outbound1fState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? showOutboundPopup,
    String? scannedDataForPopup,
    Outbound1fSmEntity? selectedMission,
    // ✨ 선택 관련 필드 제거에 따른 파라미터 정리
    bool? isMissionSelectionModeActive,
    bool? isOrderSelectionModeActive,

    RobotStatusEntity? ssrStatus,
    RobotStatusEntity? spt1fStatus,
    RobotStatusEntity? spt3fStatus,
  }) {
    return Outbound1fState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      showOutboundPopup: showOutboundPopup ?? this.showOutboundPopup,
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,
      selectedMission: selectedMission ?? this.selectedMission,

      ssrStatus: ssrStatus ?? this.ssrStatus,
      spt1fStatus: spt1fStatus ?? this.spt1fStatus,
      spt3fStatus: spt3fStatus ?? this.spt3fStatus,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    showOutboundPopup,
    scannedDataForPopup,
    selectedMission,
    ssrStatus,
    spt1fStatus,
    spt3fStatus,
  ];
}

class Outbound1FVM extends StateNotifier<Outbound1fState> {
  final Ref _ref;

  Outbound1FVM(this._ref)
    : super(
        Outbound1fState(
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

  void handleScannedData(String scannedData) {
    final isScannerModeActive = _ref.read(scannerViewModelProvider);
    if (isScannerModeActive) {
      state = state.copyWith(
        showOutboundPopup: true,
        scannedDataForPopup: scannedData,
      );
    }
  }

  void showCreationPopup() {
    state = state.copyWith(showOutboundPopup: true, scannedDataForPopup: null);
  }

  void closeCreationPopup() {
    state = state.copyWith(showOutboundPopup: false, scannedDataForPopup: null);
  }

  // 상세 정보 표시를 위한 Mission 선택 로직만 남김
  void selectMission(Outbound1fSmEntity mission) {
    state = state.copyWith(selectedMission: mission);
  }

  // 선택된 미션 초기화
  void clearSelectedMission() {
    state = state.copyWith(selectedMission: null);
  }

  // [로봇 관련 메서드]
  Future<void> pauseResumeRobot(RobotStatusEntity? robot) async {
    if (robot == null) return;
    await _ref.read(robotControlUseCaseProvider).call(robot);
  }
}

final outbound1FVMProvider =
    StateNotifierProvider<Outbound1FVM, Outbound1fState>((ref) {
      return Outbound1FVM(ref);
    });
