import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/core/domain/repositories/order_repository.dart';

import '../../../../core/providers/repository_providers.dart';
import '../entities/outbound_1f_order_entity.dart';

class Outbound1FOrderUseCase {
  final OrderRepository _orderRepository;

  Outbound1FOrderUseCase(this._orderRepository);

  /// --- Order Repository 전송 로직 ---
  Future<ResponseOrderEntity> requestOutbound1FOrder({
    required List<Outbound1FOrderEntity> outbound1FOrderEntities,
  }) async {
    final workItems = outbound1FOrderEntities
        .map(
          (entity) => WorkItem(
            missionType: entity.missionType,
            employeeId: entity.userId,
            startTime: entity.startTime,
            sourceBin: entity.sourceBin,
            destinationBin: entity.destinationBin,
            pltQty: entity.pltQty,
          ),
        )
        .toList();

    try {
      final requestOrderDto = RequestOrderDto(
        cmdId: 'RO',
        missionList: workItems,
      );

      return await _orderRepository.requestOrder(requestOrderDto);
    } catch (e) {
      rethrow;
    }
  }
}

final outbound1FOrderUseCaseProvider = Provider<Outbound1FOrderUseCase>((ref) {
  final orderRepository = ref.read(orderRepositoryProvider);
  return Outbound1FOrderUseCase(orderRepository);
});
