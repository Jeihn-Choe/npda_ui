import 'package:npda_ui_flutter/core/data/dtos/order/order_validation_req_dto.dart';
import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';

import '../entities/response_order_entity.dart';

abstract class OrderRepository {
  Future<ResponseOrderEntity> requestOrder(RequestOrderDto order);

  Future<ResponseOrderEntity> validateOrder(OrderValidationReqDto order);

  Future<ResponseOrderEntity> deleteOrder({
    List<String> uids = const [],
    List<int> subMissionNos = const [],
  });
}
