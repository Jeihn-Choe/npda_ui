import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_po_entity.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_merge_po_sm_use_case.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_dependency_provider.dart';

class OutboundPoListState extends Equatable {
  final List<OutboundPoEntity> poList;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> selectedPoKeys;
  final OutboundPoEntity? selectedPo;
  final bool isSelectionModeActive;
  final bool isDeleting;

  const OutboundPoListState({
    this.poList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedPoKeys = const {},
    this.selectedPo,
    this.isSelectionModeActive = false,
    this.isDeleting = false,
  });

  OutboundPoListState copyWith({
    List<OutboundPoEntity>? poList,
    bool? isLoading,
    String? errorMessage,
    Set<String>? selectedPoKeys,
    OutboundPoEntity? selectedPo,
    bool? isSelectionModeActive,
    bool? isDeleting,
  }) {
    return OutboundPoListState(
      poList: poList ?? this.poList,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedPoKeys: selectedPoKeys ?? this.selectedPoKeys,
      selectedPo: selectedPo ?? this.selectedPo,
      isSelectionModeActive:
          isSelectionModeActive ?? this.isSelectionModeActive,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  List<Object?> get props => [
    poList,
    isLoading,
    errorMessage,
    selectedPoKeys,
    selectedPo,
    isSelectionModeActive,
    isDeleting,
  ];
}

class OutboundPoListNotifier extends StateNotifier<OutboundPoListState> {
  StreamSubscription? _poSubscription;

  final OutboundMergePoSmUseCase _outboundMergePoSmUseCase;
  final MissionRepository _missionRepository;

  OutboundPoListNotifier({
    required OutboundMergePoSmUseCase mergeUseCase,
    required MissionRepository missionRepository,
  }) : _missionRepository = missionRepository,
       _outboundMergePoSmUseCase = mergeUseCase,
       super(const OutboundPoListState()) {
    _listenToOutboundPos();
  }

  void _listenToOutboundPos() {
    state = state.copyWith(isLoading: true);

    _poSubscription = _outboundMergePoSmUseCase.call().listen(
      (mergedPoSmList) {
        state = state.copyWith(
          poList: mergedPoSmList,
          isLoading: false,
          errorMessage: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          errorMessage: error.toString(),
          isLoading: false,
          poList: [],
        );
      },
    );
  }

  void selectPo(OutboundPoEntity po) {
    state = state.copyWith(
      selectedPo: po,
      isSelectionModeActive: false,
      selectedPoKeys: {},
    );
  }

  void enableSelectionMode(String key) {
    state = state.copyWith(isSelectionModeActive: true, selectedPoKeys: {key});
  }

  void disableSelectionMode() {
    state = state.copyWith(isSelectionModeActive: false, selectedPoKeys: {});
  }

  void togglePoForDeletion(String key) {
    final Set<String> currentSelection = Set.from(state.selectedPoKeys);
    if (currentSelection.contains(key)) {
      currentSelection.remove(key);
    } else {
      currentSelection.add(key);
    }
    state = state.copyWith(selectedPoKeys: currentSelection);
  }

  Future<bool> deleteSelectedPos() async {
    if (state.selectedPoKeys.isEmpty) {
      return false;
    }
    state = state.copyWith(isDeleting: true);
    try {
      final List<String> keysToDelete = state.selectedPoKeys.toList();
      await _missionRepository.deleteMissions(keysToDelete);
      state = state.copyWith(
        isDeleting: false,
        isSelectionModeActive: false,
        selectedPoKeys: {},
        selectedPo: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isDeleting: false,
        errorMessage: "PO 삭제 중 오류가 발생했습니다: $e",
      );
      return false;
    }
  }

  @override
  void dispose() {
    _poSubscription?.cancel();
    super.dispose();
  }
}

final outboundPoListProvider =
    StateNotifierProvider<OutboundPoListNotifier, OutboundPoListState>((ref) {
      final missionRepository = ref.watch(missionRepositoryProvider);
      final outboundMergePoSmUseCase = ref.watch(
        outboundMergePoSmUseCaseProvider,
      );
      return OutboundPoListNotifier(
        missionRepository: missionRepository,
        mergeUseCase: outboundMergePoSmUseCase,
      );
    });