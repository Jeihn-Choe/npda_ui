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
    // 유효성 검사
    List<String> missingFields = [];
    if (state.doNo.isEmpty) missingFields.add('DO No.');
    if (state.savedBinNo.isEmpty) missingFields.add('저장빈');

    if (missingFields.isNotEmpty) {
      appLogger.w('누락된 필드: $missingFields');
      throw Exception('다음 필드를 입력해주세요:\n${missingFields.join(', ')}');
    }

    state = state.copyWith(isLoading: true, resetError: true);

    try {
      final existingOrders = _ref.read(outboundOrderListProvider).orders;

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

      appLogger.i('출고 오더가 리스트에 추가됨');
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

final outboundPopupVMProvider =
    StateNotifierProvider.autoDispose<OutboundPopupVM, OutboundPopupState>((
      ref,
    ) {
      return OutboundPopupVM(ref);
    });
