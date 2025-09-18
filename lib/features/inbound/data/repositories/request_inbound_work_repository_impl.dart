import 'package:npda_ui_flutter/core/data/dtos/response_order_dto.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/data/dtos/request_order_dto.dart';
import '../../../../core/network/http/api_service.dart';
import '../../domain/repositories/request_inbound_work_repository.dart';

class RequestInboundWorkRepositoryImpl implements RequestInboundWorkRepository {
  final ApiService _apiService;

  RequestInboundWorkRepositoryImpl(this._apiService);

  @override
  Future<ResponseOrderEntity> requestInboundWork(RequestOrderDto dto) async {
    try {
      logger(dto.toString());

      final responseJson = await _apiService.post(
        ApiConfig.createOrderEndpoint,
        data: dto.toJson(),
      );
      final responseDto = ResponseOrderDto.fromJson(responseJson);

      if (responseDto.result == 'S') {
        return ResponseOrderEntity.success(cmdId: responseDto.cmdId);
      } else {
        return ResponseOrderEntity.failure(
          cmdId: responseDto.cmdId,
          message: responseDto.msg,
        );
      }
    } catch (e) {
      return ResponseOrderEntity.failure(
        cmdId: null,
        message: '작업 요청 실패: 네트워크 오류',
      );
    }
  }
}
