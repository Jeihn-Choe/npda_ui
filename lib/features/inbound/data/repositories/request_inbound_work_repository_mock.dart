import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../../core/data/dtos/request_order_dto.dart';
import '../../../../core/domain/entities/response_order_entity.dart';
import '../../domain/repositories/request_inbound_work_repository.dart';

class RequestInboundWorkRepositoryMock implements RequestInboundWorkRepository {
  @override
  Future<ResponseOrderEntity> requestInboundWork(RequestOrderDto dto) async {
    //모의 응답 생성
    await Future.delayed(Duration(seconds: 1)); //네트워크 지연 시뮬레이션

    if (dto.missionList.any((item) => item.pltNo?.contains('M') ?? false)) {
      logger('강제 실패 반환');
      return ResponseOrderEntity.failure(
        cmdId: null,
        message: 'MOCK 서버 : PLT 번호에 M이 포함되어 있어 실패 취급',
      );
    }

    return ResponseOrderEntity.success(cmdId: dto.cmdId);
  }
}
