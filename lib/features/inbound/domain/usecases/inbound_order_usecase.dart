import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/core/domain/repositories/order_repository.dart'; // ✨ 변경: Core Repository import
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_order_entity.dart';

class InboundOrderUseCase {
  // ✨ 변경: Core Repository에 의존
  final OrderRepository _repository;

  InboundOrderUseCase(this._repository);

  Future<ResponseOrderEntity> call({
    required List<InboundOrderEntity> items,
  }) async {
    if (items.isEmpty) {
      return ResponseOrderEntity.failure(cmdId: null, msg: '등록된 입고 항목이 없습니다.');
    }

    final workItems = items.map((item) {
      return WorkItem(
        missionType: 0,
        pltNo: item.pltNo,
        startTime: item.workStartTime,
        targetRackLevel: int.tryParse(item.selectedRackLevel.substring(0, 1)) ?? 0,
        employeeId: item.userId,
        sourceBin: null,
        destinationBin: null,
        isWrapped: item.isWrapped,
        destinationArea: null,
      );
    }).toList();

    final requestOrderDto = RequestOrderDto(
      cmdId: 'RO',
      missionList: workItems,
    );

    // ✨ 변경: Core Repository의 공통 메서드 호출
    return await _repository.requestOrder(requestOrderDto);
  }
}
