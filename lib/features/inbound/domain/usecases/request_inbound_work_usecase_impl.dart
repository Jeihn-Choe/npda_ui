import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/features/inbound/domain/usecases/request_inbound_work_usecase.dart';

import '../entities/inbound_registration_item.dart';
import '../repositories/request_inbound_work_repository.dart';

class RequestInboundWorkUseCaseImpl implements RequestInboundWorkUseCase {
  final RequestInboundWorkRepository _repository;

  RequestInboundWorkUseCaseImpl(this._repository);

  @override
  Future<ResponseOrderEntity> call({
    required List<InboundRegistrationItem> items,
  }) async {
    if (items.isEmpty) {
      return ResponseOrderEntity.failure(
        cmdId: null,
        message: '등록된 입고 항목이 없습니다.',
      );
    }

    /// 받은거 토대로 requestOrderDto 조립
    /// .map()으로 각 item을 WorkItem 객체로 변환

    final workItems = items.map((item) {
      //InboundRegistrationItem 의 데이터로 WorkItem 객체 생성
      return WorkItem(
        missionType: 0,
        pltNo: item.pltNo,
        startTime: item.workStartTime!,
        targetRackLevel:
            int.tryParse(item.selectedRackLevel.substring(0, 1)) ?? 0,
        employeeId: item.userId,
        sourceBin: null,
        destinationBin: null,
        isWrapped: item.isWrapped,
        destinationArea: null,
      );
    }).toList(); // .map() 으로 변환된 각 Workitem을 toList()로 다시 리스트로 변환

    final requestOrderDto = RequestOrderDto(
      cmdId: 'SO', // 입고 작업
      missionList: workItems,
    ); // DTO 조립 완료

    return await _repository.requestInboundWork(requestOrderDto);
  }
}
