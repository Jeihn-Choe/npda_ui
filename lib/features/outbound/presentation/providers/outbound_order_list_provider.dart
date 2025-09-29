import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/features/outbound/domain/entities/outbound_order_entity.dart';

/// viewmodel에 제공해야하는 상태들

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
  OutboundOrderListNotifier() : super(const OutboundOrderListState());

  void addOrder(OutboundOrderEntity newOrder) {
    /// orders 를 ...스프레드 연산자로 리스트를 펼치고, newOrder를 추가
    state = state.copyWith(orders: [...state.orders, newOrder]);
  }
}

final outboundOrderListProvider =
    StateNotifierProvider<OutboundOrderListNotifier, OutboundOrderListState>((
      ref,
    ) {
      return OutboundOrderListNotifier();
    });
