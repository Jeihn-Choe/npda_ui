import '../entities/inbound_po_entity.dart';

abstract class InboundPoRepository {
  Stream<List<InboundPoEntity>> get inboundPoStream;
}
