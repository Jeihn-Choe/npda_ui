import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_order_entity.dart';

// ✨ 삭제: UseCase 파일을 직접 import 하지 않음
// import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_order_usecase.dart';
// ✨ 추가: dependency_provider 파일을 import
import 'package:npda_ui_flutter/features/outbound/presentation/providers/outbound_dependency_provider.dart';

import '../../domain/usecases/outbound_order_usecase.dart';

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
  List<Object?> get props =>
      [
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

  // ✨ 변경: 반환 타입을 Future<int>로 수정
  Future<int> requestOutboundOrder() async {
    // ✨ 추가: 요청 전, 현재 아이템 개수를 변수에 저장
    final itemCount = state.orders.length;
    if (itemCount == 0) {
      throw Exception('요청할 작업이 없습니다.');
    }

    state = state.copyWith(isLoading: true);
    try {
      // UseCase의 파라미터명 변경 (items -> outboundOrderEntities)
      final result = await _orderUseCase.requestOutboundOrder(
        outboundOrderEntities: state.orders,
      );

      if (result.isSuccess) {
        // ✨ 변경: 성공 시 리스트를 비우고, 저장해둔 아이템 개수를 반환
        clearOrders();
        return itemCount;
      } else {
        // ✨ 변경: result.msg를 result.message로 수정
        throw Exception(result.message);
      }
    } catch (e) {
      // ✨ 변경: 에러를 다시 던져서 UI에서 처리하도록 함
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final outboundOrderListProvider =
StateNotifierProvider<OutboundOrderListNotifier, OutboundOrderListState>((
    ref,) {
  final orderUseCase = ref.watch(outboundOrderUseCaseProvider);
  return OutboundOrderListNotifier(orderUseCase);
});
