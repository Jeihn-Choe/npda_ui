import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/order_repository.dart';
import 'package:npda_ui_flutter/core/providers/repository_providers.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
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
  final OrderRepository _orderRepository;

  OutboundPoListNotifier({
    required OutboundMergePoSmUseCase mergeUseCase,
    required OrderRepository orderRepository,
  }) : _orderRepository = orderRepository,
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

  void togglePoForDeletion(OutboundPoEntity po) {
    final String key = po.uid.isNotEmpty ? po.uid : "SUB:${po.subMissionNo}";

    final Set<String> currentSelection = Set.from(state.selectedPoKeys);

    if (currentSelection.contains(key)) {
      currentSelection.remove(key);
    } else {
      currentSelection.add(key);
    }

    // 🚀 선택된 키가 없으면 선택 모드 해제
    state = state.copyWith(
      selectedPoKeys: currentSelection,
      isSelectionModeActive: currentSelection.isNotEmpty,
    );
  }

  Future<bool> deleteSelectedPos() async {
    // 선택된 키가 없으면 종료
    if (state.selectedPoKeys.isEmpty) {
      return false;
    }

    state = state.copyWith(isDeleting: true);

    try {
      final List<String> uidsToDelete = [];
      final List<int> subMissionNosToDelete = [];

      // 현재 po List를 순회하면서 key랑 매치되는 값을 찾아서 분류
      for (final po in state.poList) {
        final key = po.uid.isNotEmpty ? po.uid : "SUB:${po.subMissionNo}";

        if (state.selectedPoKeys.contains(key)) {
          if (po.uid.isNotEmpty) {
            uidsToDelete.add(po.uid);
          } else if (po.subMissionNo != null) {
            subMissionNosToDelete.add(po.subMissionNo!);
          }
        }
      }

      appLogger.i(
        "🗑️ [Outbound Delete Request] UIDs: $uidsToDelete, SubMissionNos: $subMissionNosToDelete",
      );

      await _orderRepository.deleteOrder(
        uids: uidsToDelete,
        subMissionNos: subMissionNosToDelete,
      );
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
      final orderRepository = ref.watch(orderRepositoryProvider);
      final outboundMergePoSmUseCase = ref.watch(
        outboundMergePoSmUseCaseProvider,
      );
      return OutboundPoListNotifier(
        orderRepository: orderRepository,
        mergeUseCase: outboundMergePoSmUseCase,
      );
    });
