import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/current_inbound_mission_entity.dart';
import '../domain/usecases/get_current_inbound_missions_usecase.dart';

class CurrentInboundMissionState {
  final List<CurrentInboundMissionEntity> currentInboundMissions;
  final bool isLoading;
  final String? errorMessage;
  final Set<int> selectedMissionNos;
  final CurrentInboundMissionEntity? selectedMission;
  final bool isSelectionModeActive;

  const CurrentInboundMissionState({
    this.currentInboundMissions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedMissionNos = const {},
    this.selectedMission,
    this.isSelectionModeActive = false,
  });

  CurrentInboundMissionState copyWith({
    List<CurrentInboundMissionEntity>? currentInboundMissions,
    bool? isLoading,
    String? errorMessage,
    Set<int>? selectedMissionNos,
    CurrentInboundMissionEntity? selectedMission,
    bool? isSelectionModeActive,
  }) {
    return CurrentInboundMissionState(
      currentInboundMissions:
          currentInboundMissions ?? this.currentInboundMissions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMissionNos: selectedMissionNos ?? this.selectedMissionNos,
      selectedMission: selectedMission ?? this.selectedMission,
      isSelectionModeActive:
          isSelectionModeActive ?? this.isSelectionModeActive,
    );
  }
}

class InboundViewModel extends StateNotifier<CurrentInboundMissionState> {
  final GetCurrentInboundMissionsUseCase _getCurrentInboundMissionsUseCase;
  StreamSubscription? _missionSubscription;

  InboundViewModel({
    required GetCurrentInboundMissionsUseCase getCurrentInboundMissionsUseCase,
  }) : _getCurrentInboundMissionsUseCase = getCurrentInboundMissionsUseCase,
       super(const CurrentInboundMissionState()) {
    _listenToInboundMissions(); // Viewmodel 생성 시 스트림 구독 시작
  }

  void _listenToInboundMissions() {
    state = state.copyWith(isLoading: true); // 로딩 시작
    _missionSubscription = _getCurrentInboundMissionsUseCase().listen(
      (missions) {
        // 데이터 수신 성공 시
        state = state.copyWith(
          currentInboundMissions: missions,
          isLoading: false,
        );
      },
      onError: (error) {
        // 에러 발생 시
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  /// 사용자가 미션을 터치했을 때 :
  /// isSelectionModeActive false 변경
  /// 상세보기 내용 띄워줌.
  void selectMission(CurrentInboundMissionEntity mission) {
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
    state = state.copyWith(selectedMissionNos: currentSelection);
  }

  //StateNotifier를 dispose할 때 스트림 구독 취소
  @override
  void dispose() {
    _missionSubscription?.cancel();
    super.dispose();
  }
}
