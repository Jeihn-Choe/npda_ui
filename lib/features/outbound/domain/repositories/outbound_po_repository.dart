// lib/features/outbound/domain/repositories/outbound_po_repository.dart

import '../entities/outbound_po_entity.dart';

abstract class OutboundPoRepository {
  Stream<List<OutboundPoEntity>> get outboundPoStream;
}
