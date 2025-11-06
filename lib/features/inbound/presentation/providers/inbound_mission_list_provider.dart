import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_mission_entity.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/inbound_mission_usecase.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';

// 1. State 클래스
class InboundMissionListState extends Equatable {
  final List<InboundMissionEntity> missions;
  final bool isLoading;
  final String? errorMessage;
  final Set<int> selectedMissionNos;
  final InboundMissionEntity? selectedMission;
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
    List<InboundMissionEntity>? missions,
    bool? isLoading,
    String? errorMessage,
    Set<int>? selectedMissionNos,
    InboundMissionEntity? selectedMission,
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
  final InboundMissionUseCase _getInboundMissionsUseCase;
  final MissionRepository _missionRepository;
  StreamSubscription? _missionSubscription;

  InboundMissionListNotifier({
    required InboundMissionUseCase getInboundMissionsUseCase,
    required MissionRepository missionRepository,
  }) : _getInboundMissionsUseCase = getInboundMissionsUseCase,
       _missionRepository = missionRepository,
       super(const InboundMissionListState()) {
    _listenToInboundMissions();
  }

  void _listenToInboundMissions() {
    state = state.copyWith(isLoading: true);

    _getInboundMissionsUseCase.startListening();

    _missionSubscription = _getInboundMissionsUseCase.inboundMissionStream
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

  void selectMission(InboundMissionEntity mission) {
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
      final getInboundMissionsUseCase = ref.watch(
        inboundMissionUseCaseProvider,
      );
      final missionRepository = ref.watch(missionRepositoryProvider);
      return InboundMissionListNotifier(
        getInboundMissionsUseCase: getInboundMissionsUseCase,
        missionRepository: missionRepository,
      );
    });
