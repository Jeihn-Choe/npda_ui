import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../config/app_config.dart';
import '../../domain/entities/response_order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../network/http/api_service.dart';

class OrderRepositoryImpl extends OrderRepository {
  final ApiService _apiService;

  OrderRepositoryImpl(this._apiService);

  @override
  Future<ResponseOrderEntity> requestOrder(RequestOrderDto order) async {
    appLogger.i({order.toString(), 'Order 요청 시도'});
    try {
      final response = await _apiService.post(
        ApiConfig.createOrderEndpoint,
        data: order.toJson(),
      );

      final bool isSuccess = response['isSuccess'] ?? false;
      final String message =
          response['message'] ??
          (isSuccess ? '요청이 성공적으로 처리되었습니다.' : '요청 처리에 실패했습니다.');

      if (isSuccess) {
        return ResponseOrderEntity.success(msg: message);
      } else {
        return ResponseOrderEntity.failure(msg: message);
      }
    } catch (e) {
      appLogger.e('Order 요청 실패');
      return ResponseOrderEntity.failure(
        msg: '네트워크 오류 또는 알 수 없는 문제로 요청에      실패했습니다.',
      );
    }
  }
}
