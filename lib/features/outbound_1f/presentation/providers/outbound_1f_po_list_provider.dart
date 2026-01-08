import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/repositories/order_repository.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../../core/providers/repository_providers.dart';
import '../../domain/entities/outbound_1f_po_entity.dart';
import '../../domain/repositories/outbound_1f_po_repository.dart';
import 'outbound_1f_dependency_provider.dart';

// ✨ 1층 출고 PO 리스트 상태 클래스
class Outbound1fPoListState extends Equatable {
  final List<Outbound1fPoEntity> poList;
  final Set<String> selectedPoKeys;
  final bool isSelectionModeActive;
  final bool isDeleting;
  final String? errorMessage;

  final bool isLoading;

  const Outbound1fPoListState({
    this.poList = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedPoKeys = const {},
    this.isSelectionModeActive = false,
    this.isDeleting = false,
  });

  Outbound1fPoListState copyWith({
    List<Outbound1fPoEntity>? poList,
    Set<String>? selectedPoKeys,
    bool? isSelectionModeActive,
    bool? isDeleting,
    bool? isLoading,
    String? errorMessage,
  }) {
    return Outbound1fPoListState(
      poList: poList ?? this.poList,
      selectedPoKeys: selectedPoKeys ?? this.selectedPoKeys,
      isSelectionModeActive:
          isSelectionModeActive ?? this.isSelectionModeActive,
      isDeleting: isDeleting ?? this.isDeleting,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    poList,
    isLoading,
    errorMessage,
    selectedPoKeys,
    isSelectionModeActive,
    isDeleting,
  ];
}

// ✨ 1층 출고 PO 리스트 관리 Notifier
class Outbound1fPoListNotifier extends StateNotifier<Outbound1fPoListState> {
  final Outbound1fPoRepository _repository;
  final OrderRepository _orderRepository;
  StreamSubscription? _subscription;

  Outbound1fPoListNotifier(this._repository, this._orderRepository)
    : super(const Outbound1fPoListState()) {
    _init();
  }

  void _init() {
    state = state.copyWith(isLoading: true);
    // 🚀 Repository 스트림 구독
    _subscription = _repository.outbound1fPoStream.listen(
      (poList) {
        state = state.copyWith(poList: poList, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  void togglePoForDeletion(Outbound1fPoEntity po) {
    final key = po.uid;
    final currentSelection = Set<String>.from(state.selectedPoKeys);

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

  void enableSelectionMode(String key) {
    state = state.copyWith(isSelectionModeActive: true, selectedPoKeys: {key});
  }

  void disableSelectionMode() {
    state = state.copyWith(isSelectionModeActive: false, selectedPoKeys: {});
  }

  Future<bool> deleteSelectedPos() async {
    if (state.selectedPoKeys.isEmpty) return false;

    state = state.copyWith(isDeleting: true);

    try {
      final List<String> keysToDelete = state.selectedPoKeys.toList();

      appLogger.i(
        "🗑️ [Outbound1F Delete Request] Count: ${keysToDelete.length}, UIDs: $keysToDelete",
      );

      await _orderRepository.deleteOrder(uids: keysToDelete);

      state = state.copyWith(
        isSelectionModeActive: false,
        selectedPoKeys: {},
        isDeleting: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isDeleting: false, errorMessage: e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// ✨ 1층 출고 PO 리스트 제공 Provider
final outbound1fPoListProvider =
    StateNotifierProvider<Outbound1fPoListNotifier, Outbound1fPoListState>((
      ref,
    ) {
      final repository = ref.watch(outbound1fPoRepositoryProvider);
      final orderRepository = ref.watch(orderRepositoryProvider);
      return Outbound1fPoListNotifier(repository, orderRepository);
    });
