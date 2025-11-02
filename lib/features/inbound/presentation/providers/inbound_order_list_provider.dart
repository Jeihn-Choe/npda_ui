import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_order_entity.dart';
import 'package:npda_ui_flutter/features/inbound/presentation/providers/inbound_providers.dart';

import '../../domain/usecases/inbound_order_usecase.dart';

// 1. State 클래스
class InboundOrderListState extends Equatable {
  final List<InboundOrderEntity> orders;
  final Set<String> selectedPltNos;
  final bool isLoading;

  const InboundOrderListState({
    this.orders = const [],
    this.selectedPltNos = const {},
    this.isLoading = false,
  });

  InboundOrderListState copyWith({
    List<InboundOrderEntity>? orders,
    Set<String>? selectedPltNos,
    bool? isLoading,
  }) {
    return InboundOrderListState(
      orders: orders ?? this.orders,
      selectedPltNos: selectedPltNos ?? this.selectedPltNos,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [orders, selectedPltNos, isLoading];
}

// 2. Notifier 클래스
class InboundOrderListNotifier extends StateNotifier<InboundOrderListState> {
  final InboundOrderUseCase _requestInboundWorkUseCase;

  InboundOrderListNotifier(this._requestInboundWorkUseCase)
    : super(const InboundOrderListState());

  Future<void> addInboundOrder({
    required String? pltNo,
    required DateTime? workStartTime,
    required String? userId,
    required String? selectedRackLevel,
  }) async {
    try {
      logger('addInboundOrder 메서드 호출됨');
      if (pltNo == null || pltNo.isEmpty) throw ArgumentError('PltNo 누락');
      if (workStartTime == null) throw ArgumentError('WorkStartTime 누락');
      if (userId == null || userId.isEmpty) throw ArgumentError('UserId 누락');
      if (selectedRackLevel == null || selectedRackLevel.isEmpty)
        throw ArgumentError('SelectedRackLevel 누락');

      if (state.orders.any((item) => item.pltNo == pltNo)) {
        throw Exception('Plt Number 중복입니다.');
      }

      final newItem = InboundOrderEntity(
        pltNo: pltNo,
        workStartTime: workStartTime,
        userId: userId,
        selectedRackLevel: selectedRackLevel,
        isWrapped: false,
      );

      final newOrderList = [...state.orders, newItem];
      state = state.copyWith(orders: newOrderList);
    } catch (e) {
      logger('Error adding inbound order: $e');
      rethrow;
    }
  }

  void toggleOrderSelection(String pltNo) {
    final newSelectedPltNos = Set<String>.from(state.selectedPltNos);
    if (newSelectedPltNos.contains(pltNo)) {
      newSelectedPltNos.remove(pltNo);
    } else {
      newSelectedPltNos.add(pltNo);
    }
    state = state.copyWith(selectedPltNos: newSelectedPltNos);
  }

  void deleteSelectedOrders() {
    final newOrders = state.orders
        .where((order) => !state.selectedPltNos.contains(order.pltNo))
        .toList();
    state = state.copyWith(orders: newOrders, selectedPltNos: {});
  }

  void disableSelectionMode() {
    state = state.copyWith(selectedPltNos: {});
  }

  Future<int> requestInboundWork() async {
    final orderCount = state.orders.length;
    if (orderCount == 0) {
      throw Exception('요청할 작업이 없습니다.');
    }
    state = state.copyWith(isLoading: true);
    try {
      final response = await _requestInboundWorkUseCase(items: state.orders);
      if (response.isSuccess) {
        state = state.copyWith(orders: [], selectedPltNos: {});
        return orderCount;
      } else {
        throw Exception(response.msg ?? '알 수 없는 오류가 발생했습니다.');
      }
    } catch (e) {
      logger('Error requesting inbound work: $e');
      rethrow;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// 3. Provider
final inboundOrderListProvider =
    StateNotifierProvider<InboundOrderListNotifier, InboundOrderListState>((
      ref,
    ) {
      final requestInboundWorkUseCase = ref.watch(inboundOrderUseCaseProvider);
      return InboundOrderListNotifier(requestInboundWorkUseCase);
    });
