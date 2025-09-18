// 입고 기능 데이터 통신에 대한 명세서
import '../../../../core/data/dtos/request_order_dto.dart';
import '../../../../core/domain/entities/response_order_entity.dart';

abstract class RequestInboundWorkRepository {
  //작업 요청을 서버로 전송하는 기능
  Future<ResponseOrderEntity> requestInboundWork(
    RequestOrderDto requestOrderDto,
  );
}
