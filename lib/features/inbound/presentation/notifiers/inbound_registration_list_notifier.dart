import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/request_inbound_work_usecase.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/usecases/add_inbound_item_usecase.dart';
import '../state/inbound_registration_list_state.dart';

class InboundRegistrationListNotifier
    extends StateNotifier<InboundRegistrationListState> {
  // 새로운 작업을 저장할 때 Usecase 선언
  final AddInboundItemUseCase _addInboundItemUseCase;

  // 작업 요청 Usecase 선언
  final RequestInboundWorkUseCase _requestInboundWorkUseCase;

  InboundRegistrationListNotifier(
    this._addInboundItemUseCase,
    this._requestInboundWorkUseCase,
  ) : super(const InboundRegistrationListState());

  /// UI의 호출을 받아 Usecase를 호출하고 상태를 업데이트
  Future<void> addInboundItem({
    required String? pltNo,
    required DateTime? workStartTime,
    required String? userId,
    required String? selectedRackLevel,
  }) async {
    try {
      // Usecase 호출하여 새로운 아이템리스트 얻기
      final newItemList = await _addInboundItemUseCase(
        currentList: state.items,
        pltNo: pltNo,
        workStartTime: workStartTime,
        userId: userId,
        selectedRackLevel: selectedRackLevel,
      );
      // 상태 업데이트
      state = state.copyWith(items: newItemList);
    } catch (e) {
      // 에러 처리 (필요시 로깅 등)
      logger('Error adding inbound item: $e');
      // 에러를 다시 던져서 UI에서 처리할 수 있도록 함
      rethrow;
    }
  }

  /// 입고 작업 리스트 토글
  void toggleItemSelection(String pltNo) {
    final newSelectedPltNos = Set<String>.from(state.selectedPltNos);
    if (newSelectedPltNos.contains(pltNo)) {
      newSelectedPltNos.remove(pltNo);
    } else {
      newSelectedPltNos.add(pltNo);
    }
    state = state.copyWith(selectedPltNos: newSelectedPltNos);
  }

  /// 입고리스트 일부 삭제
  void deletedSelectionItems() {
    final newItems = state.items
        .where((item) => !state.selectedPltNos.contains(item.pltNo))
        .toList();
    state = state.copyWith(items: newItems, selectedPltNos: {});
  }

  /// 선택 모드 해제
  void disableSelectionMode() {
    state = state.copyWith(selectedPltNos: {});
  }

  Future<ResponseOrderEntity> requestInboundWork() async {
    // 상태를 로딩으로 변경
    state = state.copyWith(isLoading: true);

    try {
      // 현재 상태에 있는 아이템 리스트를 UseCase에 전달, 작업 요청.
      final response = await _requestInboundWorkUseCase(items: state.items);

      // 요청 성공 시
      if (response.isSuccess) {
        state = state.copyWith(items: [], selectedPltNos: {});
      }

      return response;
    } catch (e) {
      logger('Error requesting inbound work: $e');
      return ResponseOrderEntity.failure(msg: e.toString());
    } finally {
      // 작업 성공, 실패에 관계없이 상황이 종료되면 로딩 상태를 false 로 변경
      state = state.copyWith(isLoading: false);
    }
  }
}
