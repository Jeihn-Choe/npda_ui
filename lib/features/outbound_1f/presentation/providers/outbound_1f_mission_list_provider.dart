import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart'; // ✨ 추가: MissionRepository 임포트
import 'package:npda_ui_flutter/core/providers/repository_providers.dart'; // ✨ 추가: repository_providers 임포트
import 'package:npda_ui_flutter/features/outbound_1f/presentation/providers/outbound_1f_dependency_provider.dart';

import '../../domain/entities/outbound_1f_mission_entity.dart';
// ✨ 제거: UseCase 임포트 삭제
// import '../../domain/usecases/outbound_1f_mission_usecase.dart';

// ✨ 추가: Outbound1FMissionRepository 임포트
import '../../domain/repositories/outbound_1f_mission_repository.dart';


// ✨ 1. 상태 클래스 필드명 변경 및 타입 수정
class Outbound1FMissionListState extends Equatable {
  final List<Outbound1FMissionEntity> missions;
  final bool isMissionListLoading;

  // ✨ 선택 관련 상태
  final Set<int> selectedMissionNos; // 타입 Set<String> -> Set<int>
  final bool isMissionSelectionModeActive;
  final bool isMissionDeleting;

  const Outbound1FMissionListState({
    this.missions = const [],
    this.isMissionListLoading = false,
    this.selectedMissionNos = const {},
    this.isMissionSelectionModeActive = false,
    this.isMissionDeleting = false,
  });

  Outbound1FMissionListState copyWith({
    List<Outbound1FMissionEntity>? missions,
    bool? isMissionListLoading,
    Set<int>? selectedMissionNos,
    bool? isMissionSelectionModeActive,
    bool? isMissionDeleting,
  }) {
    return Outbound1FMissionListState(
      missions: missions ?? this.missions,
      isMissionListLoading: isMissionListLoading ?? this.isMissionListLoading,
      selectedMissionNos: selectedMissionNos ?? this.selectedMissionNos,
      isMissionSelectionModeActive:
          isMissionSelectionModeActive ?? this.isMissionSelectionModeActive,
      isMissionDeleting: isMissionDeleting ?? this.isMissionDeleting,
    );
  }

  @override
  List<Object?> get props => [
        missions,
        isMissionListLoading,
        selectedMissionNos,
        isMissionSelectionModeActive,
        isMissionDeleting
      ];
}

// ✨ 2. Notifier 로직 통합 및 수정
class Outbound1FMissionListNotifier
    extends StateNotifier<Outbound1FMissionListState> {
  // ✨ 변경: UseCase 대신 Repository 사용 (읽기 전용)
  final Outbound1FMissionRepository _outbound1FMissionRepository;
  // ✨ 추가: Core MissionRepository 사용 (삭제 전용)
  final MissionRepository _missionRepository;
  StreamSubscription? _missionSubscription;

  Outbound1FMissionListNotifier({
    // ✨ 변경: 파라미터 타입 변경
    required Outbound1FMissionRepository outbound1FMissionRepository,
    required MissionRepository missionRepository,
  }) : _outbound1FMissionRepository = outbound1FMissionRepository,
       _missionRepository = missionRepository,
       super(const Outbound1FMissionListState()) {
    listenToMissions();
  }

  void listenToMissions() {
    state = state.copyWith(isMissionListLoading: true);

    // ✨ 변경: Repository 스트림 구독
    _missionSubscription = _outbound1FMissionRepository.outbound1fMissionStream.listen(
      (missions) {
        state = state.copyWith(
          missions: missions,
          isMissionListLoading: false,
        );
      },
      onError: (error) {
        state = state.copyWith(isMissionListLoading: false);
      },
    );
  }

  // 🚀 선택 모드 활성화
  void enableSelectionMode(int missionNo) {
    state = state.copyWith(
      isMissionSelectionModeActive: true,
      selectedMissionNos: {missionNo},
    );
  }

  // 🚀 선택 모드 비활성화
  void disableSelectionMode() {
    state = state.copyWith(
      isMissionSelectionModeActive: false,
      selectedMissionNos: {},
    );
  }

  // 🚀 삭제할 아이템 토글 (이름 변경: toggleMissionSelection -> toggleMissionForDeletion)
  void toggleMissionForDeletion(int missionNo) {
    final currentSelection = Set<int>.from(state.selectedMissionNos);
    if (currentSelection.contains(missionNo)) {
      currentSelection.remove(missionNo);
    } else {
      currentSelection.add(missionNo);
    }
    state = state.copyWith(selectedMissionNos: currentSelection);
  }

  // 🚀 선택된 미션 삭제
  Future<bool> deleteSelectedMissions() async {
    if (state.selectedMissionNos.isEmpty) return false;

    state = state.copyWith(isMissionDeleting: true);

    try {
      await _missionRepository.deleteMissions(
        state.selectedMissionNos.map((e) => e.toString()).toList(),
      );
      state = state.copyWith(
        isMissionDeleting: false,
        isMissionSelectionModeActive: false,
        selectedMissionNos: {},
      );
      return true;
    } catch (e) {
      state = state.copyWith(isMissionDeleting: false);
      return false;
    }
  }

  @override
  void dispose() {
    _missionSubscription?.cancel();
    super.dispose();
  }
}

final outbound1FMissionListProvider =
    StateNotifierProvider<Outbound1FMissionListNotifier, Outbound1FMissionListState>(
        (ref) {
  // ✨ 변경: outbound1FMissionRepositoryProvider watch
  final outbound1FMissionRepository = ref.watch(outbound1fMissionRepositoryProvider);
  final missionRepository = ref.watch(missionRepositoryProvider); // ✨ 추가: MissionRepository watch
  return Outbound1FMissionListNotifier(
    // ✨ 변경: 파라미터 이름 변경
    outbound1FMissionRepository: outbound1FMissionRepository,
    missionRepository: missionRepository,
  );
});