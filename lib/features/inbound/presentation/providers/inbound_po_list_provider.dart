import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/mission_repository.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_po_entity.dart';
import 'package:npda_ui_flutter/features/inbound/domain/repositories/inbound_po_repository.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_dependency_provider.dart';

class InboundPoListState extends Equatable {
  final List<InboundPoEntity> poList;
  final bool isLoading;
  final String? errorMessage;
  final Set<String> selectedPoKeys;
  final InboundPoEntity? selectedPo;
  final bool isSelectionModeActive;
  final bool isDeleting;

  const InboundPoListState({
    this.poList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedPoKeys = const {},
    this.selectedPo,
    this.isSelectionModeActive = false,
    this.isDeleting = false,
  });

  InboundPoListState copyWith({
    List<InboundPoEntity>? poList,
    bool? isLoading,
    String? errorMessage,
    Set<String>? selectedPoKeys,
    InboundPoEntity? selectedPo,
    bool? isSelectionModeActive,
    bool? isDeleting,
  }) {
    return InboundPoListState(
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

class InboundPoListNotifier extends StateNotifier<InboundPoListState> {
  final InboundPoRepository _inboundPoRepository;
  final MissionRepository _missionRepository;
  StreamSubscription? _poSubscription;

  InboundPoListNotifier({
    required InboundPoRepository inboundPoRepository,
    required MissionRepository missionRepository,
  }) : _inboundPoRepository = inboundPoRepository,
       _missionRepository = missionRepository,
       super(const InboundPoListState()) {
    _listenToInboundPos();
  }

  void _listenToInboundPos() {
    state = state.copyWith(isLoading: true);

    _poSubscription = _inboundPoRepository.inboundPoStream.listen(
      (poList) {
        state = state.copyWith(
          poList: poList,
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

  void selectPo(InboundPoEntity po) {
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

final inboundPoListProvider =
    StateNotifierProvider<InboundPoListNotifier, InboundPoListState>((ref) {
      final inboundPoRepository = ref.watch(inboundPoRepositoryProvider);
      final missionRepository = ref.watch(missionRepositoryProvider);
      return InboundPoListNotifier(
        inboundPoRepository: inboundPoRepository,
        missionRepository: missionRepository,
      );
    });
