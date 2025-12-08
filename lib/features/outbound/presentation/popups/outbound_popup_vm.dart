import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/state/session_manager.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../providers/outbound_dependency_provider.dart';
import '../providers/outbound_order_list_provider.dart';

class OutboundPopupState {
  final String doNo;
  final String savedBinNo;
  final DateTime? startTime;
  final String? userId;
  final bool isLoading;
  final String? error;

  const OutboundPopupState({
    this.doNo = '',
    this.savedBinNo = '',
    this.startTime,
    this.userId,
    this.isLoading = false,
    this.error,
  });

  OutboundPopupState copyWith({
    String? doNo,
    String? savedBinNo,
    DateTime? startTime,
    String? userId,
    bool? isLoading,
    String? error,
    bool resetError = false,
  }) {
    return OutboundPopupState(
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
    return 'OutboundPopupState(doNo: $doNo, savedBinNo: $savedBinNo, startTime: $startTime, userId: $userId, isLoading: $isLoading, error: $error)';
  }
}

class OutboundPopupVM extends StateNotifier<OutboundPopupState> {
  OutboundPopupVM(this._ref) : super(const OutboundPopupState());

  final Ref _ref;

  void initialize({String? scannedData, String? userId}) {
    String initialDoNo = '';
    String initialSavedBinNo = '';

    final sessionState = _ref.watch(sessionManagerProvider);

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
      userId: sessionState.userId!,
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
    // 유효성 검사: DO No.와 저장빈 중 정확히 하나만 입력되어야 함
    final bool doNoEmpty = state.doNo.isEmpty;
    final bool savedBinNoEmpty = state.savedBinNo.isEmpty;

    if (doNoEmpty && savedBinNoEmpty) {
      throw Exception('DO No. 또는 저장빈 중 하나를 입력해주세요');
    }

    if (!doNoEmpty && !savedBinNoEmpty) {
      throw Exception('DO No. 또는 저장빈 중 하나만 입력해주세요');
    }

    state = state.copyWith(isLoading: true, resetError: true);

    // TODO : 중복 검사 구현
    try {
      final existingOrders = _ref.read(outboundOrderListProvider).orders;

      appLogger.d("Existing outbound orders count: ${existingOrders.length}");
      if (state.doNo.isNotEmpty) {
        final duplicateOrder = existingOrders.firstWhere(
          (order) => order.doNo == state.doNo,
        );
        appLogger.d(
          "Checking for duplicate DO No.: ${state.doNo}, Found: $duplicateOrder",
        );
        if (duplicateOrder != null) {
          throw Exception('DO No. 또는 저장빈 중 하나만 입력해주세요');
        }
      }

      final (newOrder, errorMessage) = _ref
          .read(outboundOrderUseCaseProvider)
          .addOrder(
            doNo: state.doNo,
            savedBinNo: state.savedBinNo,
            startTime: state.startTime!,
            userId: state.userId!,
            existingOrders: existingOrders,
          );

      if (errorMessage != null || newOrder == null) {
        state = state.copyWith(isLoading: false, error: errorMessage);
        return false;
      }

      _ref.read(outboundOrderListProvider.notifier).addOrderToList(newOrder);

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: '오더 저장 중 오류가 발생했습니다.');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

final outboundPopupVMProvider =
    StateNotifierProvider.autoDispose<OutboundPopupVM, OutboundPopupState>((
      ref,
    ) {
      return OutboundPopupVM(ref);
    });
