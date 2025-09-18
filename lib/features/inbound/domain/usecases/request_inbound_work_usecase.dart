import 'package:npda_ui_flutter/core/domain/entities/response_order_entity.dart';
import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_registration_item.dart';

abstract class RequestInboundWorkUseCase {
  Future<ResponseOrderEntity> call({
    required List<InboundRegistrationItem> items,
  });
}
