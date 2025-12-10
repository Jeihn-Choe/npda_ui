import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart'; // ✨ 추가: MissionRepository 임포트
import 'package:npda_ui_flutter/core/providers/repository_providers.dart'; // ✨ 추가: repository_providers 임포트

// ✨ 제거: UseCase 임포트 삭제
// import '../../domain/usecases/outbound_mission_usecase.dart';
import '../../domain/entities/outbound_sm_entity.dart';
import '../../domain/repositories/outbound_sm_repository.dart';
import 'outbound_dependency_provider.dart'; // outboundMissionRepositoryProvider를 가져오기 위해 필요

// ✨ 추가: OutboundMissionRepository 임포트

// 1. State 클래스 확장 및 Equatable 상속
class OutboundMissionListState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<OutboundSmEntity> missions;

  // ✨ 미션 선택 관련 상태 추가
  final Set<int> selectedMissionNos;
  final OutboundSmEntity? selectedMission;
  final bool isMissionSelectionModeActive;
  final bool isMissionDeleting;

  const OutboundMissionListState({
    this.isLoading = false,
    this.errorMessage,
    this.missions = const [],
    // ✨ 기본값 초기화
    this.selectedMissionNos = const {},
    this.selectedMission,
    this.isMissionSelectionModeActive = false,
    this.isMissionDeleting = false,
  });

  OutboundMissionListState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<OutboundSmEntity>? missions,
    Set<int>? selectedMissionNos,
    OutboundSmEntity? selectedMission,
    bool? isMissionSelectionModeActive,
    bool? isMissionDeleting,
  }) {
    return OutboundMissionListState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      missions: missions ?? this.missions,
      // ✨ copyWith 로직 추가
      selectedMissionNos: selectedMissionNos ?? this.selectedMissionNos,
      selectedMission: selectedMission ?? this.selectedMission,
      isMissionSelectionModeActive:
          isMissionSelectionModeActive ?? this.isMissionSelectionModeActive,
      isMissionDeleting: isMissionDeleting ?? this.isMissionDeleting,
    );
  }

  // ✨ props에 상태 추가
  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    missions,
    selectedMissionNos,
    selectedMission,
    isMissionSelectionModeActive,
    isMissionDeleting,
  ];
}

// ✨ 2. Notifier에 로직 메소드 추가
class OutboundMissionListNotifier
    extends StateNotifier<OutboundMissionListState> {
  final OutboundSmRepository _outboundMissionRepository;
  final MissionRepository _missionRepository;
  StreamSubscription? _missionSubscription;

  OutboundMissionListNotifier({
    required OutboundSmRepository outboundMissionRepository,
    required MissionRepository missionRepository,
  }) : _outboundMissionRepository = outboundMissionRepository,
       _missionRepository = missionRepository,
       super(const OutboundMissionListState()) {
    _listenToMissions();
  }

  void _listenToMissions() {
    state = state.copyWith(isLoading: true);

    // ✨ 변경: Repository 스트림 구독
    _missionSubscription = _outboundMissionRepository.outboundSmStream.listen(
      (missions) {
        state = state.copyWith(
          missions: missions,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
        );
      },
    );
  }

  void selectMission(OutboundSmEntity mission) {
    state = state.copyWith(
      selectedMission: mission,
      isMissionSelectionModeActive: false,
      selectedMissionNos: {},
    );
  }

  void enableSelectionMode(int subMissionNo) {
    state = state.copyWith(
      isMissionSelectionModeActive: true,
      selectedMissionNos: {subMissionNo},
    );
  }

  void disableSelectionMode() {
    state = state.copyWith(
      isMissionSelectionModeActive: false,
      selectedMissionNos: {},
    );
  }

  void toggleMissionForDeletion(int subMissionNo) {
    final currentSelection = Set<int>.from(state.selectedMissionNos);
    if (currentSelection.contains(subMissionNo)) {
      currentSelection.remove(subMissionNo);
    } else {
      currentSelection.add(subMissionNo);
    }
    state = state.copyWith(selectedMissionNos: currentSelection);
  }

  Future<bool> deleteSelectedOutboundMissions() async {
    if (state.selectedMissionNos.isEmpty) {
      return false;
    }

    state = state.copyWith(isMissionDeleting: true);

    try {
      var selectedMissions = state.selectedMissionNos
          .map((e) => e.toString())
          .toList();
      await _missionRepository.deleteMissions(selectedMissions);

      state = state.copyWith(
        isMissionDeleting: false,
        isMissionSelectionModeActive: false,
        selectedMissionNos: {},
        selectedMission: null,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isMissionDeleting: false,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  @override
  void dispose() {
    _missionSubscription?.cancel();
    super.dispose();
  }
}

final outboundMissionListProvider =
    StateNotifierProvider<
      OutboundMissionListNotifier,
      OutboundMissionListState
    >((ref) {
      final outboundMissionRepository = ref.watch(outboundSmRepositoryProvider);
      final missionRepository = ref.watch(
        missionRepositoryProvider,
      ); // ✨ 추가: MissionRepository watch

      return OutboundMissionListNotifier(
        outboundMissionRepository: outboundMissionRepository,
        missionRepository: missionRepository,
      );
    });
