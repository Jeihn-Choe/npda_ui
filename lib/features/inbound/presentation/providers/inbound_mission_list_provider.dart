import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_dependency_provider.dart';

import '../../domain/entities/inbound_sm_entity.dart';
import '../../domain/repositories/inbound_sm_repository.dart';

// 1. State 클래스 (기존과 동일)
class InboundMissionListState extends Equatable {
  final List<InboundSmEntity> missions;
  final bool isLoading;
  final String? errorMessage;
  final Set<int> selectedMissionNos;
  final InboundSmEntity? selectedMission;
  final bool isSelectionModeActive;
  final bool isDeleting;

  const InboundMissionListState({
    this.missions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedMissionNos = const {},
    this.selectedMission,
    this.isSelectionModeActive = false,
    this.isDeleting = false,
  });

  InboundMissionListState copyWith({
    List<InboundSmEntity>? missions,
    bool? isLoading,
    String? errorMessage,
    Set<int>? selectedMissionNos,
    InboundSmEntity? selectedMission,
    bool? isSelectionModeActive,
    bool? isDeleting,
  }) {
    return InboundMissionListState(
      missions: missions ?? this.missions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedMissionNos: selectedMissionNos ?? this.selectedMissionNos,
      selectedMission: selectedMission ?? this.selectedMission,
      isSelectionModeActive:
          isSelectionModeActive ?? this.isSelectionModeActive,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
    missions,
    isLoading,
    errorMessage,
    selectedMissionNos,
    selectedMission,
    isSelectionModeActive,
    isDeleting,
  ];
}

// 2. Notifier 클래스
class InboundMissionListNotifier
    extends StateNotifier<InboundMissionListState> {
  // ✨ 변경: UseCase 대신 Repository 사용 (읽기 전용)
  final InboundSmRepository _inboundMissionRepository;

  // ✨ 유지: Core Repository 사용 (삭제 전용)
  final MissionRepository _missionRepository;
  StreamSubscription? _missionSubscription;

  InboundMissionListNotifier({
    // ✨ 변경: 파라미터 타입 변경
    required InboundSmRepository inboundMissionRepository,
    required MissionRepository missionRepository,
  }) : _inboundMissionRepository = inboundMissionRepository,
       _missionRepository = missionRepository,
       super(const InboundMissionListState()) {
    _listenToInboundMissions();
  }

  void _listenToInboundMissions() {
    state = state.copyWith(isLoading: true);

    _missionSubscription = _inboundMissionRepository.inboundMissionStream
        .listen(
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
              missions: [],
            );
          },
        );
  }

  void selectMission(InboundSmEntity mission) {
    state = state.copyWith(
      selectedMission: mission,
      isSelectionModeActive: false,
      selectedMissionNos: {},
    );
  }

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

  Future<bool> deleteSelectedInboundMissions() async {
    if (state.selectedMissionNos.isEmpty) {
      return false;
    }
    state = state.copyWith(isDeleting: true);
    try {
      final List<String> missionNosToDelete = state.selectedMissionNos
          .map((e) => e.toString())
          .toList();
      await _missionRepository.deleteMissions(missionNosToDelete);
      state = state.copyWith(
        isDeleting: false,
        isSelectionModeActive: false,
        selectedMissionNos: {},
        selectedMission: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        errorMessage: "미션 삭제 중 오류가 발생했습니다: $e",
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

// 3. Provider
final inboundMissionListProvider =
    StateNotifierProvider<InboundMissionListNotifier, InboundMissionListState>((
      ref,
    ) {
      // ✨ 변경: inboundMissionRepositoryProvider watch
      final inboundMissionRepository = ref.watch(
        inboundMissionRepositoryProvider,
      );
      final missionRepository = ref.watch(missionRepositoryProvider);
      return InboundMissionListNotifier(
        // ✨ 변경: 파라미터 이름 변경
        inboundMissionRepository: inboundMissionRepository,
        missionRepository: missionRepository,
      );
    });
