import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/delete_missions_usecase.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/inbound_mission_usecase.dart';

import '../../../core/state/scanner_viewmodel.dart';
import '../domain/entities/inbound_mission_entity.dart';

class InboundMissionState {
  final List<InboundMissionEntity> inboundMissions;
  final bool isLoading;
  final String? errorMessage;
  final Set<int> selectedMissionNos;
  final InboundMissionEntity? selectedMission;
  final bool isSelectionModeActive;
  final String? scannedDataForPopup;
  final bool showInboundPopup;

  /// 미션 삭제
  final bool isDeleting;

  const InboundMissionState({
    this.inboundMissions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedMissionNos = const {},
    this.selectedMission,
    this.isSelectionModeActive = false,
    this.scannedDataForPopup,
    this.showInboundPopup = false,
    this.isDeleting = false,
  });

  InboundMissionState copyWith({
    List<InboundMissionEntity>? inboundMissions,
    bool? isLoading,
    String? errorMessage,
    Set<int>? selectedMissionNos,
    InboundMissionEntity? selectedMission,
    bool? isSelectionModeActive,
    String? scannedDataForPopup,
    bool? showInboundPopup,
    bool? isDeleting,
  }) {
    return InboundMissionState(
      inboundMissions: inboundMissions ?? this.inboundMissions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMissionNos: selectedMissionNos ?? this.selectedMissionNos,
      selectedMission: selectedMission ?? this.selectedMission,
      isSelectionModeActive:
          isSelectionModeActive ?? this.isSelectionModeActive,
      scannedDataForPopup: scannedDataForPopup ?? this.scannedDataForPopup,
      showInboundPopup: showInboundPopup ?? this.showInboundPopup,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }
}

class InboundViewModel extends StateNotifier<InboundMissionState> {
  final InboundMissionUseCase _getInboundMissionsUseCase;
  final DeleteMissionsUseCase _deleteMissionsUseCase;

  final Ref _ref;
  StreamSubscription? _missionSubscription;

  InboundViewModel({
    required InboundMissionUseCase getInboundMissionsUseCase,
    required DeleteMissionsUseCase deleteMissionsUseCase,
    required Ref ref,
  }) : _getInboundMissionsUseCase = getInboundMissionsUseCase,
       _deleteMissionsUseCase = deleteMissionsUseCase,
       _ref = ref,
       super(const InboundMissionState()) {
    _listenToInboundMissions(); // Viewmodel 생성 시 스트림 구독 시작
  }

  // 스캔된 데이터 처리/ 팝업 띄우는 메서드
  void handleScannedData(String scannedData) {
    logger("인바운드 viewmodel handleScannedData 호출");
    logger("- 스캔된 데이터: $scannedData");

    final isScannerModeActive = _ref.read(scannerViewModelProvider);

    if (isScannerModeActive) {
      state = state.copyWith(
        scannedDataForPopup: scannedData,
        showInboundPopup: true,
      );
    } else {
      logger("스캐너모드가 비활성화되어 팝업이 표시되지 않습니다.");
    }
  }

  // 팝업 표시 상태 초기화 메서드
  void clearInboundPopup() {
    state = state.copyWith(scannedDataForPopup: null, showInboundPopup: false);
  }

  //팝업 상태를 직접 설정하는 메서드 필요
  void setInboundPopupState(bool isShowing) {
    state = state.copyWith(showInboundPopup: isShowing);
  }

  void _listenToInboundMissions() {
    state = state.copyWith(isLoading: true);
    _missionSubscription = _getInboundMissionsUseCase.inboundMissionStream.listen(
      (missions) {
        // 데이터 수신 성공 시
        state = state.copyWith(
          inboundMissions: missions,
          isLoading: false,
          errorMessage: null, // 에러 메시지 초기화
        );
      },
      onError: (error) {
        // 에러 발생 시
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
          inboundMissions: [], // 에러 발생 시 기존 목록을 비움
        );
      },
    );
  }

  /// 사용자가 미션을 터치했을 때 :
  /// isSelectionModeActive false 변경
  /// 상세보기 내용 띄워줌.
  void selectMission(InboundMissionEntity mission) {
    state = state.copyWith(
      selectedMission: mission,
      isSelectionModeActive: false,
      selectedMissionNos: {},
    );
  }

  /// 사용자가 미션을 길게 터치했을 때 :
  /// isSelectionModeActive true 변경
  /// 해당 미션을 selectedMissionNos에 추가
  void enableSelectionMode(int missionNo) {
    state = state.copyWith(
      isSelectionModeActive: true,
      selectedMissionNos: {missionNo},
    );
  }

  /// 셀렉션 모드 해제
  void disableSelectionMode() {
    state = state.copyWith(
      isSelectionModeActive: false,
      selectedMissionNos: {},
    );
  }

  void toggleMissionForDeletion(int missionNo) {
    final Set<int> currentSelection = Set.from(state.selectedMissionNos);
    if (currentSelection.contains(missionNo)) {
      currentSelection.remove(missionNo);
    } else {
      currentSelection.add(missionNo);
    }

    logger("토글된 미션 번호: $missionNo");
    logger("현재 선택된 미션 번호들: $currentSelection");

    state = state.copyWith(selectedMissionNos: currentSelection);
  }

  Future<bool> deleteSelectedInboundMissions() async {
    // modified
    if (state.selectedMissionNos.isEmpty) {
      logger("삭제할 미션이 선택되지 않았습니다.");
      return false; // modified
    }

    state = state.copyWith(isDeleting: true);

    logger('selectedMissionNos: ${state.selectedMissionNos}');

    try {
      final List<String> missionNosToDelete = state.selectedMissionNos
          .map((e) => e.toString())
          .toList();

      await _deleteMissionsUseCase.call(missionNosToDelete);

      state = state.copyWith(
        isDeleting: false,
        isSelectionModeActive: false,
        selectedMissionNos: {},
        selectedMission: null,
      );
      logger(" 선택된 미션 삭제요청 완료 : $missionNosToDelete");
      return true; // modified
    } catch (e) {
      logger("미션 삭제 중 오류 발생: $e");
      state = state.copyWith(
        isDeleting: false,
        errorMessage: "미션 삭제 중 오류가 발생했습니다: $e",
      );
      return false; // modified
    }
  }

  //StateNotifier를 dispose할 때 스트림 구독 취소
  @override
  void dispose() {
    _missionSubscription?.cancel();
    super.dispose();
  }
}
