import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';

import '../entities/response_order_entity.dart';

abstract class OrderRepository {
  Future<ResponseOrderEntity> requestOrder(RequestOrderDto order);
}
