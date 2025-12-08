import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/outbound_1f/domain/entities/outbound_1f_order_entity.dart';
import 'package:npda_ui_flutter/features/outbound_1f/domain/usecases/outbound_1f_order_usecase.dart';

// ✨ 1. 상태 클래스에 선택 관련 필드 추가
class Outbound1FOrderListState extends Equatable {
  final List<Outbound1FOrderEntity> orders;
  final bool isLoading;
  final String? errorMessage;

  // ✨ 선택 관련 상태
  final Set<String> selectedOrderNos;
  final bool isOrderSelectionModeActive;
  final bool isOrderDeleting;

  const Outbound1FOrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    // ✨ 기본값 초기화
    this.selectedOrderNos = const {},
    this.isOrderSelectionModeActive = false,
    this.isOrderDeleting = false,
  });

  Outbound1FOrderListState copyWith({
    List<Outbound1FOrderEntity>? orders,
    bool? isLoading,
    String? errorMessage,
    // ✨ copyWith 파라미터 추가
    Set<String>? selectedOrderNos,
    bool? isOrderSelectionModeActive,
    bool? isOrderDeleting,
  }) {
    return Outbound1FOrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      // ✨ copyWith 로직 추가
      selectedOrderNos: selectedOrderNos ?? this.selectedOrderNos,
      isOrderSelectionModeActive:
          isOrderSelectionModeActive ?? this.isOrderSelectionModeActive,
      isOrderDeleting: isOrderDeleting ?? this.isOrderDeleting,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    isLoading,
    errorMessage,
    // ✨ props에 추가
    selectedOrderNos,
    isOrderSelectionModeActive,
    isOrderDeleting,
  ];
}

// ✨ 2. Notifier에 선택 관련 로직 추가
class Outbound1FOrderListNotifier
    extends StateNotifier<Outbound1FOrderListState> {
  final Outbound1FOrderUseCase _orderUseCase;

  Outbound1FOrderListNotifier(this._orderUseCase)
    : super(const Outbound1FOrderListState());

  void addOrderToList(Outbound1FOrderEntity newOrder) {
    state = state.copyWith(orders: [...state.orders, newOrder]);
  }

  void clearOrders() {
    state = state.copyWith(orders: []);
  }

  // 🚀 선택 모드 활성화
  void enableOrderSelectionMode(String orderNo) {
    state = state.copyWith(
      isOrderSelectionModeActive: true,
      selectedOrderNos: {orderNo},
    );
  }

  // 🚀 선택 모드 비활성화
  void disableOrderSelectionMode() {
    state = state.copyWith(
      isOrderSelectionModeActive: false,
      selectedOrderNos: {},
    );
  }

  // 🚀 삭제할 아이템 토글
  void toggleOrderForDeletion(String orderNo) {
    final currentSelection = Set<String>.from(state.selectedOrderNos);
    if (currentSelection.contains(orderNo)) {
      currentSelection.remove(orderNo);
    } else {
      currentSelection.add(orderNo);
    }
    state = state.copyWith(selectedOrderNos: currentSelection);
  }

  // 🚀 선택된 주문 삭제 (기존 removeOrders 대체)
  void deleteSelectedOrders() {
    if (state.selectedOrderNos.isEmpty) {
      return;
    }
    state = state.copyWith(isOrderDeleting: true);
    try {
      final updatedOrders = state.orders
          .where((order) => !state.selectedOrderNos.contains(order.orderNo))
          .toList();
      state = state.copyWith(
        orders: updatedOrders,
        isOrderDeleting: false,
        isOrderSelectionModeActive: false,
        selectedOrderNos: {},
      );
    } catch (e) {
      state = state.copyWith(isOrderDeleting: false);
    }
  }

  Future<void> requestOutbound1FOrder() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _orderUseCase.requestOutbound1FOrder(
        outbound1FOrderEntities: state.orders,
      );

      if (result.isSuccess) {
        clearOrders();
      }
    } catch (e) {
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final outbound1FOrderListProvider =
    StateNotifierProvider<
      Outbound1FOrderListNotifier,
      Outbound1FOrderListState
    >((ref) {
      final orderUseCase = ref.watch(outbound1FOrderUseCaseProvider);
      return Outbound1FOrderListNotifier(orderUseCase);
    });
