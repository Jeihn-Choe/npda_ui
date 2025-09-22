import 'package:npda_ui_flutter/core/data/dtos/response_order_dto.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/core/utils/logger.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/data/dtos/request_order_dto.dart';
import '../../../../core/network/http/api_service.dart';
import '../../domain/repositories/request_inbound_work_repository.dart';

class RequestInboundWorkRepositoryImpl implements RequestInboundWorkRepository {
  final ApiService _apiService;

  RequestInboundWorkRepositoryImpl(this._apiService);

  @override
  Future<ResponseOrderEntity> requestInboundWork(RequestOrderDto dto) async {
    try {
      final responseJson = await _apiService.post(
        ApiConfig.createOrderEndpoint,
        data: dto.toJson(),
      );

      final responseDto = ResponseOrderDto.fromJson(responseJson.data);

      logger('=======INOBOUND WORK REPOSITORY : response 응답받음====== ');

      if (responseDto.result == "S") {
        return ResponseOrderEntity.success(cmdId: responseDto.cmdId);
      } else {
        return ResponseOrderEntity.failure(
          cmdId: responseDto.cmdId,
          msg: responseDto.msg,
        );
      }
    } catch (e) {
      return ResponseOrderEntity.failure(
        cmdId: null,
        msg: 'REPOSITORY_IMPL : 작업 요청 실패: 네트워크 오류',
      );
    }
  }
}
