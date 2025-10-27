import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:npda_ui_flutter/core/data/dtos/request_order_dto.dart';
import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';

import '../../../../core/providers/repository_providers.dart';
import '../entities/outbound_order_entity.dart';

class UseCaseResult {
  final bool isSuccess;
  final String message;

  UseCaseResult({required this.isSuccess, required this.message});
}

class OutboundOrderUseCase {
  OutboundOrderUseCase(this.ref);

  final Ref ref;

  /// --- 주문 추가 로직 ---
  (OutboundOrderEntity?, String?) addOrder({
    required String doNo,
    required String savedBinNo,
    required DateTime startTime,
    required String userId,
    required List<OutboundOrderEntity> existingOrders,
  }) {
    // 중복 주문 확인
    if (doNo.isNotEmpty && existingOrders.any((order) => order.doNo == doNo)) {
      return (null, '이미 등록된 DO 번호 입니다.');
    }

    // 저장빈 중복 확인
    if (savedBinNo.isNotEmpty &&
        existingOrders.any((order) => order.savedBinNo == savedBinNo)) {
      return (null, '이미 등록된 저장빈 번호 입니다.');
    }

    // 새로운 주문 생성
    final newOrder = OutboundOrderEntity(
      orderNo: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      // 예시로 고유한 주문 번호 생성
      doNo: doNo.isEmpty ? null : doNo,
      savedBinNo: savedBinNo.isEmpty ? null : savedBinNo,
      userId: userId,
      startTime: DateTime.now(),
    );

    return (newOrder, null);
  }

  /// --- Order Repository 전송 로직 ---
  Future<UseCaseResult> requestOutboundOrder({
    required List<OutboundOrderEntity> outboundOrderEntities,
  }) async {
    final orderRepository = ref.read(orderRepositoryProvider);

    final workItems = outboundOrderEntities
        .map(
          (entity) => WorkItem(
            missionType: 1,
            doNo: entity.doNo!.isNotEmpty ? entity.doNo : entity.savedBinNo,
            startTime: entity.startTime,
            employeeId: entity.userId,
          ),
        )
        .toList();

    final requestDto = RequestOrderDto(cmdId: 'RO', missionList: workItems);

    final ResponseOrderEntity response = await orderRepository.requestOrder(
      requestDto,
    );

    if (response.isSuccess) {
      return UseCaseResult(
        isSuccess: true,
        message: response.msg ?? 'Order 전송 성공',
      );
    } else {
      return UseCaseResult(
        isSuccess: false,
        message: response.msg ?? 'Order 전송 실패',
      );
    }
  }
}

final outboundOrderUseCaseProvider = Provider<OutboundOrderUseCase>((ref) {
  return OutboundOrderUseCase(ref);
});
