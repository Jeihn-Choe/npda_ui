import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/scanner_viewmodel.dart';
import 'package:npda_ui_flutter/features/outbound_1f/domain/entities/outbound_1f_mission_entity.dart';

class Outbound1FState extends Equatable {
  final bool isLoading;
  final String? errorMessage;

  // 화면 전체에 대한 상태만 남김
  final bool showOutboundPopup;
  final String? scannedDataForPopup;
  final Outbound1FMissionEntity? selectedMission; // 상세 정보 표시에 사용

  const Outbound1FState({
    this.isLoading = false,
    this.errorMessage,
    this.showOutboundPopup = false,
    this.scannedDataForPopup,
    this.selectedMission,
  });

  Outbound1FState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool? showOutboundPopup,
    String? scannedDataForPopup,
    Outbound1FMissionEntity? selectedMission,
    // ✨ 선택 관련 필드 제거에 따른 파라미터 정리
    bool? isMissionSelectionModeActive,
    bool? isOrderSelectionModeActive,
  }) {
    return Outbound1FState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      showOutboundPopup: showOutboundPopup ?? this.showOutboundPopup,
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,
      selectedMission: selectedMission ?? this.selectedMission,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    showOutboundPopup,
    scannedDataForPopup,
    selectedMission,
  ];
}

class Outbound1FVM extends StateNotifier<Outbound1FState> {
  final Ref _ref;

  Outbound1FVM(this._ref) : super(const Outbound1FState());

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
  void selectMission(Outbound1FMissionEntity mission) {
    state = state.copyWith(selectedMission: mission);
  }

  // 선택된 미션 초기화
  void clearSelectedMission() {
    state = state.copyWith(selectedMission: null);
  }
}

final outbound1FVMProvider =
    StateNotifierProvider<Outbound1FVM, Outbound1FState>((ref) {
      return Outbound1FVM(ref);
    });
