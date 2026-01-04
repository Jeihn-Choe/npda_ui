import 'package:npda_ui_flutter/core/data/dtos/order_validation_req_dto.dart';
import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/core/domain/repositories/order_repository.dart';

class OrderRepositoryMock implements OrderRepository {
  @override
  Future<ResponseOrderEntity> requestOrder(RequestOrderDto requestDto) async {
    // 1초 딜레이 후 성공 응답을 시뮬레이션합니다.
    await Future.delayed(const Duration(seconds: 1));

    // 성공 시의 Mock 응답
    return ResponseOrderEntity.success(
      msg: '${requestDto.missionList.length}건의 작업이 요청되었습니다.',
    );
  }

  @override
  Future<ResponseOrderEntity> validateOrder(OrderValidationReqDto order) async {
    await Future.delayed(const Duration(seconds: 1));

    if (order.binId.toUpperCase().contains('FAIL')) {
      return ResponseOrderEntity.failure(msg: "검증 실패");
    }

    return ResponseOrderEntity.success(msg: "");
  }
}
