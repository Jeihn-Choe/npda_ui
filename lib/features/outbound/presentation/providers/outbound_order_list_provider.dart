import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_order_entity.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_order_usecase.dart';

class OutboundOrderListState extends Equatable {
  final List<OutboundOrderEntity> orders;
  final bool isLoading;
  final String? errorMessage;

  const OutboundOrderListState({
    this.orders = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  OutboundOrderListState copyWith({
    List<OutboundOrderEntity>? orders,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OutboundOrderListState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [orders, isLoading, errorMessage];
}

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

  Future<void> requestOutboundOrder() async {
    state = state.copyWith(isLoading: true);
    try {
      final result = await _orderUseCase.requestOutboundOrder(
        items: state.orders,
      );

      if (result.isSuccess) {
        clearOrders();
      }
    } catch (e) {
      logger('Error requesting outbound work: $e');
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
