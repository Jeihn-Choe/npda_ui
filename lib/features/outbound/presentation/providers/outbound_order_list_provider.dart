import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_order_entity.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_order_usecase.dart';
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_dependency_provider.dart';

// ✨ 1. 상태 클래스에 선택 관련 필드 추가
class OutboundOrderListState extends Equatable {
  final List<OutboundOrderEntity> orders;
  final bool isLoading;
  final String? errorMessage;

  // ✨ 선택 관련 상태
  final Set<String> selectedOrderNos;
  final bool isOrderSelectionModeActive;
  final bool isOrderDeleting;

  const OutboundOrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
    // ✨ 기본값 초기화
    this.selectedOrderNos = const {},
    this.isOrderSelectionModeActive = false,
    this.isOrderDeleting = false,
  });

  OutboundOrderListState copyWith({
    List<OutboundOrderEntity>? orders,
    bool? isLoading,
    String? errorMessage,
    // ✨ copyWith 파라미터 추가
    Set<String>? selectedOrderNos,
    bool? isOrderSelectionModeActive,
    bool? isOrderDeleting,
  }) {
    return OutboundOrderListState(
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
class OutboundOrderListNotifier extends StateNotifier<OutboundOrderListState> {
  final OutboundOrderUseCase _orderUseCase;

  OutboundOrderListNotifier(this._orderUseCase)
      : super(const OutboundOrderListState());

  void addOrderToList(OutboundOrderEntity newOrder) {
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
      appLogger.w("삭제할 주문이 선택되지 않았습니다.");
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
      appLogger.d(
          "OutboundOrderListProvider: ${state.selectedOrderNos.length}개의 주문을 목록에서 제거했습니다.");
    } catch (e) {
      state = state.copyWith(isOrderDeleting: false);
      appLogger.e("주문 삭제 중 오류 발생", error: e);
    }
  }

  Future<void> requestOutboundOrder() async {
    state = state.copyWith(isLoading: true);
    try {
      // 🚀 UseCase의 파라미터명 변경 (items -> outboundOrderEntities)
      final result = await _orderUseCase.requestOutboundOrder(
        outboundOrderEntities: state.orders,
      );

      if (result.isSuccess) {
        clearOrders();
      }
    } catch (e) {
      appLogger.e('Error requesting outbound work: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final outboundOrderListProvider =
    StateNotifierProvider<OutboundOrderListNotifier, OutboundOrderListState>((
  ref,
) {
  final orderUseCase = ref.watch(outboundOrderUseCaseProvider);
  return OutboundOrderListNotifier(orderUseCase);
});
