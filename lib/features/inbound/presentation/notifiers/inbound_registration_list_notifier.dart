import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../domain/usecases/add_inbound_item_usecase.dart';
import '../state/inbound_registration_list_state.dart';

class InboundRegistrationListNotifier
    extends StateNotifier<InboundRegistrationListState> {
  final AddInboundItemUseCase addInboundItemUseCase;

  InboundRegistrationListNotifier(this.addInboundItemUseCase)
    : super(const InboundRegistrationListState());

  /// UI의 호출을 받아 Usecase를 호출하고 상태를 업데이트
  Future<void> addInboundItem({
    required String? pltNo,
    required DateTime? workStartTime,
    required String? userId,
    required String? selectedRackLevel,
  }) async {
    try {
      // Usecase 호출하여 새로운 아이템리스트 얻기
      final newItemList = await addInboundItemUseCase(
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
}
