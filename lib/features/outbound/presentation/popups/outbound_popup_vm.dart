import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';
import 'package:npda_ui_flutter/features/outbound/domain/usecases/outbound_order_usecase.dart';

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
      userId: userId ?? '12345',
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
      final existingOrders = _ref.read(outboundOrderListProvider).orders;

      final result = _ref
          .read(outboundOrderUseCaseProvider)
          .addOrder(
            doNo: state.doNo,
            savedBinNo: state.savedBinNo,
            startTime: state.startTime!,
            userId: state.userId!,
            existingOrders: existingOrders,
          );

      if (!result.isSuccess) {
        state = state.copyWith(isLoading: false, error: result.message);
        return false;
      }

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
    StateNotifierProvider<OutboundPopupVM, OutboundPopupState>((ref) {
      return OutboundPopupVM(ref);
    });
