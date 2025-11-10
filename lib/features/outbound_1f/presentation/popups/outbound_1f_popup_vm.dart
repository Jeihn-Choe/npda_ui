import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../domain/entities/outbound_1f_order_entity.dart';
import '../providers/outbound_1f_order_list_provider.dart';

class Outbound1FPopupState {
  final String sourceArea;
  final String destinationArea;
  final int quantity;
  final List<String> availableSourceAreas;
  final List<String> availableDestinationAreas;
  final DateTime? startTime;
  final String? userId;
  final bool isLoading;
  final String? error;

  const Outbound1FPopupState({
    this.sourceArea = '',
    this.destinationArea = '',
    this.quantity = 1,
    this.availableSourceAreas = const [
      '2A20-AMR-01',
      '2A20-AMR-02',
      '2A20-AMR-03',
    ],
    this.availableDestinationAreas = const [
      '2A10-AMR-01',
      '2A10-AMR-02',
      '2A10-AMR-03',
    ],
    this.startTime,
    this.userId,
    this.isLoading = false,
    this.error,
  });

  Outbound1FPopupState copyWith({
    String? sourceArea,
    String? destinationArea,
    int? quantity,
    List<String>? availableSourceAreas,
    List<String>? availableDestinationAreas,
    DateTime? startTime,
    String? userId,
    bool? isLoading,
    String? error,
    bool resetError = false,
  }) {
    return Outbound1FPopupState(
      sourceArea: sourceArea ?? this.sourceArea,
      destinationArea: destinationArea ?? this.destinationArea,
      quantity: quantity ?? this.quantity,
      availableSourceAreas: availableSourceAreas ?? this.availableSourceAreas,
      availableDestinationAreas:
          availableDestinationAreas ?? this.availableDestinationAreas,
      startTime: startTime ?? this.startTime,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: resetError ? null : error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'Outbound1FPopupState(sourceArea: $sourceArea, destinationArea: $destinationArea, quantity: $quantity, startTime: $startTime, userId: $userId, isLoading: $isLoading, error: $error)';
  }
}

class Outbound1FPopupVM extends StateNotifier<Outbound1FPopupState> {
  Outbound1FPopupVM(this._ref) : super(const Outbound1FPopupState());

  final Ref _ref;

  void initialize({String? scannedData, String? userId}) {
    String initialSourceArea = '';
    String initialDestinationArea = '';

    final sessionState = _ref.watch(sessionManagerProvider);

    // TODO: 스캔 기능은 나중에 추가될 예정
    // if (scannedData != null && scannedData.isNotEmpty) {
    //   if (scannedData.startsWith('2A20')) {
    //     initialSourceArea = scannedData;
    //   } else if (scannedData.startsWith('2A10')) {
    //     initialDestinationArea = scannedData;
    //   }
    // }

    state = state.copyWith(
      sourceArea: initialSourceArea,
      destinationArea: initialDestinationArea,
      quantity: 1,
      // 기본값으로 1 설정
      startTime: DateTime.now().toUtc().add(const Duration(hours: 9)),
      userId: sessionState.userId!,
      isLoading: false,
      resetError: true,
    );
  }

  void onSourceAreaChanged(String value) {
    state = state.copyWith(sourceArea: value, resetError: true);
  }

  void onDestinationAreaChanged(String value) {
    state = state.copyWith(destinationArea: value, resetError: true);
  }

  void onQuantityChanged(int value) {
    if (value > 0) {
      state = state.copyWith(quantity: value, resetError: true);
    }
  }

  Future<bool> saveOrder() async {
    if (state.sourceArea.isEmpty || state.destinationArea.isEmpty) {
      state = state.copyWith(error: '출발지역과 목적지역을 모두 선택해주세요.');
      return false;
    }

    if (state.quantity <= 0) {
      state = state.copyWith(error: '수량은 1 이상이어야 합니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, resetError: true);

    try {
      final existingOrders = _ref.read(outbound1FOrderListProvider).orders;

      // TODO: Outbound1FOrderEntity에 sourceArea 또는 destinationArea와 같은 고유 식별자가 없으므로 중복 검사를 수행할 수 없습니다.
      // if (state.sourceArea.isNotEmpty && existingOrders.any((order) => order.sourceArea == state.sourceArea)) {
      //   state = state.copyWith(error: '이미 등록된 출발지역 입니다.');
      //   return false;
      // }

      // 새로운 주문 생성
      final newOrder = Outbound1FOrderEntity(
        orderNo: 'ORD1F-${DateTime.now().millisecondsSinceEpoch}',
        pltQty: state.quantity,
        // 사용자가 입력한 수량 사용
        sourceBin: state.sourceArea.isNotEmpty ? state.sourceArea : null,
        destinationBin: state.destinationArea.isNotEmpty
            ? state.destinationArea
            : null,
        startTime: state.startTime!,
        userId: state.userId!,
      );

      _ref.read(outbound1FOrderListProvider.notifier).addOrderToList(newOrder);

      appLogger.i('출고(1F) 오더가 리스트에 추가됨 - 수량: ${state.quantity}');
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      appLogger.e('Error saving order: $e');
      state = state.copyWith(isLoading: false, error: '오더 저장 중 오류가 발생했습니다.');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final outbound1FPopupVMProvider =
    StateNotifierProvider.autoDispose<Outbound1FPopupVM, Outbound1FPopupState>((
      ref,
    ) {
      return Outbound1FPopupVM(ref);
    });
