import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/login/presentation/state/login_state.dart';

import '../../../login/presentation/providers/login_providers.dart';
import '../../domain/entities/outbound_1f_order_entity.dart';
import '../providers/outbound_1f_order_list_provider.dart';

class Outbound1FPopupState {
  final String doNo;
  final String savedBinNo;
  final DateTime? startTime;
  final String? userId;
  final bool isLoading;
  final String? error;

  const Outbound1FPopupState({
    this.doNo = '',
    this.savedBinNo = '',
    this.startTime,
    this.userId,
    this.isLoading = false,
    this.error,
  });

  Outbound1FPopupState copyWith({
    String? doNo,
    String? savedBinNo,
    DateTime? startTime,
    String? userId,
    bool? isLoading,
    String? error,
    bool resetError = false,
  }) {
    return Outbound1FPopupState(
      doNo: doNo ?? this.doNo,
      savedBinNo: savedBinNo ?? this.savedBinNo,
      startTime: startTime ?? this.startTime,
      userId: userId ?? this.userId,
      isLoading: isLoading ?? this.isLoading,
      error: resetError ? null : error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'Outbound1FPopupState(doNo: $doNo, savedBinNo: $savedBinNo, startTime: $startTime, userId: $userId, isLoading: $isLoading, error: $error)';
  }
}

class Outbound1FPopupVM extends StateNotifier<Outbound1FPopupState> {
  Outbound1FPopupVM(this._ref) : super(const Outbound1FPopupState());

  final Ref _ref;

  void initialize({String? scannedData, String? userId}) {
    String initialDoNo = '';
    String initialSavedBinNo = '';

    LoginState loginState = _ref.read(loginViewModelProvider);

    if (scannedData != null && scannedData.isNotEmpty) {
      if (scannedData.startsWith('2A')) {
        initialSavedBinNo = scannedData;
      } else {
        initialDoNo = scannedData;
      }
    }

    state = state.copyWith(
      doNo: initialDoNo,
      savedBinNo: initialSavedBinNo,
      startTime: DateTime.now().toUtc().add(const Duration(hours: 9)),
      userId: loginState.userId!,
      isLoading: false,
      resetError: true,
    );
  }

  void onDoNoChanged(String value) {
    state = state.copyWith(doNo: value, resetError: true);
  }

  void onSavedBinNoChanged(String value) {
    state = state.copyWith(savedBinNo: value, resetError: true);
  }

  Future<bool> saveOrder() async {
    if (state.doNo.isEmpty && state.savedBinNo.isEmpty) {
      state = state.copyWith(error: 'DO No. 또는 저장빈을 입력해주세요.');
      return false;
    }

    state = state.copyWith(isLoading: true, resetError: true);

    try {
      final existingOrders = _ref.read(outbound1FOrderListProvider).orders;

      // TODO: Outbound1FOrderEntity에 doNo 또는 savedBinNo와 같은 고유 식별자가 없으므로 중복 검사를 수행할 수 없습니다.
      // if (state.doNo.isNotEmpty && existingOrders.any((order) => order.doNo == state.doNo)) {
      //   state = state.copyWith(error: '이미 등록된 DO 번호 입니다.');
      //   return false;
      // }

      // 새로운 주문 생성
      final newOrder = Outbound1FOrderEntity(
        orderNo: 'ORD1F-${DateTime.now().millisecondsSinceEpoch}', // 🚀 추가된 부분
        // TODO: pltQty의 출처를 확인해야 합니다. 현재는 1로 하드코딩되어 있습니다.
        pltQty: 1,
        pickingArea: state.doNo.isNotEmpty ? state.doNo : null,
        unloadArea: state.savedBinNo.isNotEmpty ? state.savedBinNo : null,
        startTime: state.startTime!,
        userId: state.userId!,
      );

      _ref.read(outbound1FOrderListProvider.notifier).addOrderToList(newOrder);

      appLogger.i('출고(1F) 오더가 리스트에 추가됨');
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
