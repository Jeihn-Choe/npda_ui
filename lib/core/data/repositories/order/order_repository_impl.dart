import 'package:npda_ui_flutter/core/data/dtos/order_validation_req_dto.dart';
import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';

import '../../../config/app_config.dart';
import '../../../domain/entities/response_order_entity.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../network/http/api_service.dart';
import '../../../utils/logger.dart';

class OrderRepositoryImpl extends OrderRepository {
  final ApiService _apiService;

  OrderRepositoryImpl(this._apiService);

  @override
  Future<ResponseOrderEntity> requestOrder(RequestOrderDto order) async {
    final orderJson = order.toJson();

    try {
      final response = await _apiService.post(
        ApiConfig.createOrderEndpoint,
        data: orderJson,
      );

      final responseData = response.data;
      final String? result = responseData['result'] as String?;
      final String? msg = responseData['msg'] as String?;

      // result가 'SUCCESS' 또는 'OK' 같은 값이면 성공으로 처리
      final bool isSuccess =
          result?.toUpperCase() == 'S' || result?.toUpperCase() == 'OK';

      if (isSuccess) {
        return ResponseOrderEntity.success(msg: msg ?? '요청이 성공적으로 처리되었습니다.');
      } else {
        appLogger.w('Order request failed: $msg');
        return ResponseOrderEntity.failure(msg: msg ?? '요청 처리에 실패했습니다.');
      }
    } catch (e, stackTrace) {
      appLogger.e(
        'Order request error occurred',
        error: e,
        stackTrace: stackTrace,
      );
      return ResponseOrderEntity.failure(
        msg: '네트워크 오류 또는 알 수 없는 문제로 요청에 실패했습니다.',
      );
    }
  }

  // MOCK 임.
  @override
  Future<ResponseOrderEntity> validateOrder(OrderValidationReqDto order) async {
    await Future.delayed(const Duration(seconds: 1));

    if (order.binId.toUpperCase().contains('FAIL')) {
      return ResponseOrderEntity.failure(msg: "검증 실패");
    }

    return ResponseOrderEntity.success(msg: "");
  }

  // @override
  // Future<ResponseOrderEntity> validateOrder(OrderValidationReqDto order) async {
  //   final orderJson = order.toJson();
  //
  //   try {
  //     final response = await _apiService.post(
  //       ApiConfig.validateOrderEndpoint,
  //       data: orderJson,
  //     );
  //
  //     final responseData = response.data;
  //     final String? result = responseData['result'] as String?;
  //     final String? msg = responseData['msg'] as String?;
  //
  //     // S: 성공, F: 실패
  //     final bool isSuccess = result?.toUpperCase() == 'S';
  //
  //     if (isSuccess) {
  //       return ResponseOrderEntity.success(msg: msg ?? '유효성 검사 성공');
  //     } else {
  //       appLogger.w('주문 유효성 검사 실패: $msg');
  //       return ResponseOrderEntity.failure(msg: msg ?? 'repository : 실패');
  //     }
  //   } catch (e, stackTrace) {
  //     appLogger.e('주문 유효성 검사 중 오류 발생', error: e, stackTrace: stackTrace);
  //     return ResponseOrderEntity.failure(
  //       msg: '네트워크 오류 또는 알 수 없는 문제로 요청에 실패했습니다.',
  //     );
  //   }
  // }
}
