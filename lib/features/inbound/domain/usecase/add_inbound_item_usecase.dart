import 'package:npda_ui_flutter/features/inbound/domain/entities/inbound_registration_item.dart';

abstract class AddInboundItemUseCase {
  Future<List<InboundRegistrationItem>> call({
    required List<InboundRegistrationItem> currentList,
    required String? pltNo,
    required DateTime? workStartTime,
    required String? userId,
    required String? selectedRackLevel,
  });
}
