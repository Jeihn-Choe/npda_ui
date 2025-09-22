import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/current_inbound_mission_entity.dart';
import '../domain/usecases/get_current_inbound_missions_usecase.dart';

class CurrentInboundMissionState {
  final List<CurrentInboundMissionEntity> currentInboundMissions;
  final bool isLoading;
  final String? errorMessage;
  final Set<int> selectedMissionNos;

  const CurrentInboundMissionState({
    this.currentInboundMissions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedMissionNos = const {},
  });

  CurrentInboundMissionState copyWith({
    List<CurrentInboundMissionEntity>? currentInboundMissions,
    bool? isLoading,
    String? errorMessage,
    Set<int>? selectedMissionNos,
  }) {
    return CurrentInboundMissionState(
      currentInboundMissions:
          currentInboundMissions ?? this.currentInboundMissions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMissionNos: selectedMissionNos ?? this.selectedMissionNos,
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

  //StateNotifier를 dispose할 때 스트림 구독 취소
  @override
  void dispose() {
    _missionSubscription?.cancel();
    super.dispose();
  }
}
