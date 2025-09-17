import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_registration_item.dart';

import 'add_inbound_item_usecase.dart';

class AddInboundItemUseCaseImpl implements AddInboundItemUseCase {
  @override
  Future<List<InboundRegistrationItem>> call({
    required List<InboundRegistrationItem> currentList,
    required String? pltNo,
    required DateTime? workStartTime,
    required String? userId,
    required String? selectedRackLevel,
  }) async {
    // 유효성검사
    if (pltNo == null || pltNo.isEmpty) {
      throw ArgumentError('PltNo 누락');
    }
    if (workStartTime == null) {
      throw ArgumentError('WorkStartTime 누락');
    }
    if (userId == null || userId.isEmpty) {
      throw ArgumentError('UserId 누락');
    }
    if (selectedRackLevel == null || selectedRackLevel.isEmpty) {
      throw ArgumentError('SelectedRackLevel 누락');
    }

    // 비지니스 로직 처리
    if (currentList.any((item) => item.pltNo == pltNo)) {
      throw Exception('Plt Number 중복입니다.');
    }

    final newItem = InboundRegistrationItem(
      pltNo: pltNo,
      workStartTime: workStartTime,
      userId: userId,
      selectedRackLevel: selectedRackLevel,
    );

    return [...currentList, newItem];

    /// 새로운 리스트를 만들어서 currentList 를 spread operator(...)로 복사하고, newItem을 추가하여 반환
    /// StateNotifier의 상태는 불변(immutable)이어야 하므로, 기존 리스트를 수정하지 않고 새로운 리스트를 반환
    /// 새로운 리스트를 반환함으로써 상태가 변경됨
    /// 기존의 .add 메서드는 리스트를 직접 수정하기 때문에, 상태 변경이 감지되지 않음
    /// 따라서 UI가 다시 빌드되지 않음
    /// 반면에 새로운 리스트를 반환하면,
    /// StateNotifier는 상태가 변경되었음을 감지하고, 이를 구독하는 위젯들에게 알림
    /// 따라서 UI는 새로운 상태를 반영하여 다시 빌드됨
  }

  // Implementation of the use case to add an inbound item
}
