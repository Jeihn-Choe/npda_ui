import 'package:npda_ui_flutter/features/outbound_1f/domain/entities/outbound_1f_order_entity.dart';

class Outbound1FOrderListState {
  final bool isLoading;
  final List<Outbound1FOrderEntity> orders;

  Outbound1FOrderListState({this.isLoading = false, this.orders = const []});

  Outbound1FOrderListState copyWith({
    bool? isLoading,
    List<Outbound1FOrderEntity>? orders,
  }) {
    return Outbound1FOrderListState(
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
    );
  }
}
