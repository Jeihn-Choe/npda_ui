import '../entities/outbound_1f_po_entity.dart';

abstract class Outbound1fPoRepository {
  Stream<List<Outbound1fPoEntity>> get outbound1fPoStream;
}
